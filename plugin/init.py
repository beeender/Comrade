import os
import vim

from pathlib import Path

CONFIG_DIR = os.path.join(Path.home(), ".ComradeNeovim")


def pid_exists(pid):
    try:
        os.kill(pid, 0)
    except ProcessLookupError:  # errno.ESRCH
        return False  # No such process
    except PermissionError:  # errno.EPERM
        return True  # Operation not permitted (i.e., process exists)
    else:
        return True  # no error, we can send a signal to the process


def clean_up():
    if not os.path.isdir(CONFIG_DIR):
        return
    for file in os.listdir(CONFIG_DIR):
        filename = os.fsdecode(file)
        try:
            pid = int(filename)
        except ValueError:
            continue
        if pid < 0:
            continue

        # Remove non existing config files
        if not pid_exists(pid):
            try:
                os.remove(os.path.join(CONFIG_DIR, filename))
            except Exception:
                continue


def init():
    # Create the config dir
    if not os.path.isdir(CONFIG_DIR):
        os.makedirs(CONFIG_DIR)

    # Use PID as the file name
    pid = vim.funcs.getpid()
    addr = os.getenv("NVIM_LISTEN_ADDRESS")
    version = vim.vars['comrade_version']
    cwd = os.getcwd()
    with open(os.path.join(CONFIG_DIR, f"{pid}"), "w") as pid_file:
        pid_file.write(addr + "\n")
        pid_file.write(version + "\n")
        pid_file.write(cwd)


clean_up()
init()
