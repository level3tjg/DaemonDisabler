#include <stdio.h>
#include <spawn.h>
#include <signal.h>

int main(int argc, char *argv[], char *envp[]) {
    //launchctl wrapper. Needed to run launchctl as root without using sudo because I don't feel like using sudo. Electra / Chimera are stupid, why do I need to call setuid twice. ugh
    setuid(0);
    setuid(0);
    setgid(0);
    pid_t pid;
    int status;
    argv[0] = "launchctl";
    posix_spawn(&pid, "/bin/launchctl", NULL, NULL, argv, NULL);
    waitpid(pid, &status, WEXITED);
	return 0;
}
