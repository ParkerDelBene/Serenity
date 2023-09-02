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
    char hello[19] = "Hello from server";
    pthread_t thread_id;

    // Creating a socket file descriptor

    if((server_fd = socket(AF_INET, SOCK_STREAM,0)) < 0){
        perror("socket failed");
        exit(EXIT_FAILURE);
    }

    // Forcefully attaching socket to the port 8080

    if(setsockopt(server_fd,SOL_SOCKET,SO_REUSEADDR | SO_REUSEPORT, &opt, sizeof(opt))){
        perror("socket failed");
        exit(EXIT_FAILURE);
    }
    address.sin_family = AF_INET;
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
    printf("Listening for Connections\n");
    while(true){

        // Accepting connections and checking for success

        if((new_socket = accept(server_fd, (struct sockaddr*)&address, (socklen_t*)&addrlen)) < 0){
            perror("accept");
            exit(EXIT_FAILURE);
        }

        // Creating the Thread Handler

        if(pthread_create( &thread_id, NULL, connection_handler, (void*) &new_socket) < 0){
            perror("Thread creation faied");
            return 1;
        }


    }


    return 0;
}


/*
    Function Name: connection handler
    Author: Parker DelBene
    Date: 03/13/2023
    Description: This function is used to handle the interactions between the server and client.
        The socket details are passed by value through a void* type. The client is able tosend a message that propogates to all other clients.

*/
void *connection_handler(void *socket_desc){

    int sock = *(int*)socket_desc;
    int read_size;
    char message[74] = "Hey, this is the Server speaking. Type me anything and I will repeat it!";
    char client_message[2000];

    //Send a confirmation message to the client
    write(sock, message, strlen(message));

    while((read_size = recv(sock, client_message, 2000, 0)) > 0){

        // append null terminated string
        client_message[read_size] = '\0';

        write(sock, client_message, strlen(client_message));

        //clear the memory buffer
        memset(client_message, 0 , 2000);
    }


    if(read_size == 0){
        puts("Client disconnected");
        fflush(stdout);
    }
    else if(read_size == -1){
        perror("recv failed");
    }


    return 0;
}