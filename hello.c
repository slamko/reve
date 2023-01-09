#include <stdio.h>
#include <unistd.h>

int main(int argc, char **argv) {
    char *arg[] = {"/bin/echo", "hello", NULL};
    char *env[] = {"PATH=/bin/echo", NULL};

    execve("/bin/echo", arg, env);
    return 0;
}
