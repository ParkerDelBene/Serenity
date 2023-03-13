#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>
#include <pthread.h>
#define PORT 8080


void *connection_handler(void *);

int main(int argc, char const* argv[]){



    int server_fd, new_socket, valthread;
    struct sockaddr_in address;
    int opt = 1;
    int addrlen = sizeof(address);
    char buffer[1024] = {0};
    char* hello = "Hello from server";

    // Creating a socket file descriptor

    if((server_fd = socket(AF_INET, SOCK_STREAM,0)) < 0){
        perror("socket failed");
        exit(EXIT_FAILURE);
    }

    // Forcefully attaching socket to the port 8080

    if(setsockopt(server_fd,SOL_SOCKET,SO_REUSEADDR | SO_REUSEPORT, $opt, sizeof(opt))){
        perror("socket failed");
        exit(EXIT_FAILURE);
    }
    address.sin_family = AF_NET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(PORT);


    if(bind(server_fd, (struct sockaddr*)&address, sizeof(address)) < 0){
        perror("bind failed");
        exit(EXIT_FAILURE);
    }
    
    if(listen(server_fd, 3) < 0){
        perror("listen");
        exit(EXIT_FAILURE);
    }


    /*
        Main Server Loop:

    */
    while(true){

        // Accepting connections and checking for success

        if((new_socket = accept(server_fd, (struct sockaddr*)&address, (socklen_t*)&addrlen)) < 0){
            perror("accept");
            exit(EXIT_FAILURE);
        }





    }


    return 0;
}