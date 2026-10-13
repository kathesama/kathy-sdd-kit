"""Bounded argument-vector execution; never an OS permission sandbox."""
import os
from pathlib import Path
import re
import signal
import subprocess
import threading
import time
from .evidence import number, validate_command

LIMIT = 65536


def redact(text: str) -> str:
    text = re.sub(r'(?i)\b(token|password|secret|api[_-]?key)\s*[:=]\s*[^\s]+', r'\1=[REDACTED]', text)
    text = re.sub(r'(?i)Bearer\s+[^\s]+', 'Bearer [REDACTED]', text)
    text = re.sub(r'\b(?:sk-|ghp_|github_pat_)[A-Za-z0-9_-]{12,}', '[REDACTED]', text)
    return text.encode()[:LIMIT].decode('utf-8', errors='ignore')


def _windows_job():
    """Create a kill-on-close job before starting any process (fail closed)."""
    import ctypes
    from ctypes import wintypes
    class Basic(ctypes.Structure):
        _fields_ = [('per_process', ctypes.c_longlong), ('per_job', ctypes.c_longlong),
                    ('flags', wintypes.DWORD), ('min_ws', ctypes.c_size_t), ('max_ws', ctypes.c_size_t),
                    ('active', wintypes.DWORD), ('affinity', ctypes.c_size_t),
                    ('priority', wintypes.DWORD), ('scheduling', wintypes.DWORD)]
    class IO(ctypes.Structure):
        _fields_ = [(name, ctypes.c_ulonglong) for name in ('read', 'write', 'other', 'read_b', 'write_b', 'other_b')]
    class Extended(ctypes.Structure):
        _fields_ = [('basic', Basic), ('io', IO), ('process_memory', ctypes.c_size_t),
                    ('job_memory', ctypes.c_size_t), ('peak_process', ctypes.c_size_t), ('peak_job', ctypes.c_size_t)]
    api = ctypes.WinDLL('kernel32', use_last_error=True)
    api.CreateJobObjectW.argtypes = [ctypes.c_void_p, wintypes.LPCWSTR]
    api.CreateJobObjectW.restype = wintypes.HANDLE
    api.SetInformationJobObject.argtypes = [wintypes.HANDLE, ctypes.c_int, ctypes.c_void_p, wintypes.DWORD]
    api.AssignProcessToJobObject.argtypes = [wintypes.HANDLE, wintypes.HANDLE]
    api.CloseHandle.argtypes = [wintypes.HANDLE]
    job = api.CreateJobObjectW(None, None)
    settings = Extended()
    settings.basic.flags = 0x2000  # JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE
    if not job:
        raise OSError(ctypes.get_last_error(), 'Cannot create bounded process job')
    if not api.SetInformationJobObject(job, 9, ctypes.byref(settings), ctypes.sizeof(settings)):
        api.CloseHandle(job)
        raise OSError(ctypes.get_last_error(), 'Cannot configure bounded process job')
    return api, job


def execute(argv: list[str], cwd: Path, timeout: float = 120) -> dict:
    validate_command(argv)
    number(timeout, positive=True)
    started = time.time()
    deadline = time.monotonic() + timeout
    api = job = process = None
    streams = [bytearray(), bytearray()]
    timed_out = False
    threads = []
    def drain(pipe, destination):
        try:
            while chunk := pipe.read(4096):
                destination.extend(chunk[:max(0, LIMIT - len(destination))])
        finally:
            pipe.close()
    try:
        if os.name == 'nt':
            api, job = _windows_job()
        process = subprocess.Popen(argv, cwd=cwd, shell=False, stdin=subprocess.DEVNULL,
                                   stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                   start_new_session=os.name != 'nt',
                                   creationflags=0x4 if os.name == 'nt' else 0)
        if job:
            import ctypes
            if not api.AssignProcessToJobObject(job, int(process._handle)):
                raise OSError('Cannot constrain process tree')
            native = ctypes.WinDLL('ntdll')
            native.NtResumeProcess.argtypes = [ctypes.c_void_p]
            if native.NtResumeProcess(int(process._handle)) != 0:
                raise OSError('Cannot resume constrained process')
        for pipe, destination in zip((process.stdout, process.stderr), streams):
            thread = threading.Thread(target=drain, args=(pipe, destination), daemon=True)
            thread.start()
            threads.append(thread)
        try:
            process.wait(timeout=max(0.001, deadline-time.monotonic()))
        except subprocess.TimeoutExpired:
            timed_out = True
    finally:
        if job:
            api.CloseHandle(job)  # Includes descendants even after the parent exits.
        elif process and os.name != 'nt':
            try:
                os.killpg(process.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
        if process:
            if process.poll() is None:
                process.kill()
            process.wait(timeout=3)
        for thread in threads:
            thread.join(timeout=3)
        if any(thread.is_alive() for thread in threads):
            raise RuntimeError('Process-tree cleanup incomplete; result unknown')
    finished = time.time()
    stdout, stderr = [redact(bytes(data).decode('utf-8', errors='replace')) for data in streams]
    if timed_out:
        stderr = ('timeout: process tree terminated\n' + stderr)[:LIMIT]
    return dict(exit_code=process.returncode, outcome='unknown' if timed_out else ('passed' if process.returncode == 0 else 'failed'),
                stdout=stdout, stderr=stderr, started=started, finished=finished, duration=finished-started)
