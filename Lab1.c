#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Structure to represent a student
struct Student {
    int SID;
    char NAME[50];
    char BRANCH[50];
    int SEMESTER;
    char ADDRESS[100];
};

// Function to insert a new student
void insertStudent() {
    FILE *outfile;
    struct Student student;

    outfile = fopen("students.txt", "a");
    if (outfile == NULL) {
        printf("Error opening file.\n");
        return;
    }

    printf("\nEnter SID: ");
    scanf("%d", &student.SID);

    // Clear the input buffer
    while (getchar() != '\n');

    printf("Enter Name: ");
    fgets(student.NAME, sizeof(student.NAME), stdin);
    student.NAME[strlen(student.NAME) - 1] = '\0'; // Remove the newline character

    printf("Enter Branch: ");
    fgets(student.BRANCH, sizeof(student.BRANCH), stdin);
    student.BRANCH[strlen(student.BRANCH) - 1] = '\0'; // Remove the newline character

    printf("Enter Semester: ");
    scanf("%d", &student.SEMESTER);

    // Clear the input buffer
    while (getchar() != '\n');

    printf("Enter Address: ");
    fgets(student.ADDRESS, sizeof(student.ADDRESS), stdin);
    student.ADDRESS[strlen(student.ADDRESS) - 1] = '\0'; // Remove the newline character

    fprintf(outfile, "%d %s %s %d %s\n", student.SID, student.NAME, student.BRANCH, student.SEMESTER, student.ADDRESS);

    fclose(outfile);
}


// Function to modify the address of a student based on SID
void modifyAddress(int sid) {
    FILE *infile, *tempFile;
    struct Student student;

    infile = fopen("students.txt", "r");
    if (infile == NULL) {
        printf("Error opening file.\n");
        return;
    }

    tempFile = fopen("temp.txt", "w");
    if (tempFile == NULL) {
        printf("Error opening file.\n");
        fclose(infile);
        return;
    }

    while (fscanf(infile, "%d %s %s %d %s", &student.SID, student.NAME, student.BRANCH, &student.SEMESTER, student.ADDRESS) != EOF) {
        if (student.SID == sid) {
            printf("Enter new Address: ");
            scanf("%s", student.ADDRESS);
        }
        fprintf(tempFile, "%d %s %s %d %s\n", student.SID, student.NAME, student.BRANCH, student.SEMESTER, student.ADDRESS);
    }

    fclose(infile);
    fclose(tempFile);

    remove("students.txt");
    rename("temp.txt", "students.txt");
}

// Function to delete a student based on SID
void deleteStudent(int sid) {
    FILE *infile, *tempFile;
    struct Student student;

    infile = fopen("students.txt", "r");
    if (infile == NULL) {
        printf("Error opening file.\n");
        return;
    }

    tempFile = fopen("temp.txt", "w");
    if (tempFile == NULL) {
        printf("Error opening file.\n");
        fclose(infile);
        return;
    }

    while (fscanf(infile, "%d %s %s %d %s", &student.SID, student.NAME, student.BRANCH, &student.SEMESTER, student.ADDRESS) != EOF) {
        if (student.SID != sid) {
            fprintf(tempFile, "%d %s %s %d %s\n", student.SID, student.NAME, student.BRANCH, student.SEMESTER, student.ADDRESS);
        }
    }

    fclose(infile);
    fclose(tempFile);

    remove("students.txt");
    rename("temp.txt", "students.txt");
}

// Function to list all students
void listAllStudents() {
    FILE *infile;
    struct Student student;

    infile = fopen("students.txt", "r");
    if (infile == NULL) {
        printf("Error opening file.\n");
        return;
    }

    while (fscanf(infile, "%d %s %s %d %s", &student.SID, student.NAME, student.BRANCH, &student.SEMESTER, student.ADDRESS) != EOF) {
        printf("SID: %d, Name: %s, Branch: %s, Semester: %d, Address: %s\n", student.SID, student.NAME, student.BRANCH, student.SEMESTER, student.ADDRESS);
    }

    fclose(infile);
}

// Function to list all students of a specific branch
void listStudentsByBranch(char *branch) {
    FILE *infile;
    struct Student student;

    infile = fopen("students.txt", "r");
    if (infile == NULL) {
        printf("Error opening file.\n");
        return;
    }

    while (fscanf(infile, "%d %s %s %d %s", &student.SID, student.NAME, student.BRANCH, &student.SEMESTER, student.ADDRESS) != EOF) {
        if (strcmp(student.BRANCH, branch) == 0) {
            printf("SID: %d, Name: %s, Branch: %s, Semester: %d, Address: %s\n", student.SID, student.NAME, student.BRANCH, student.SEMESTER, student.ADDRESS);
        }
    }

    fclose(infile);
}

// Function to list all students of a specific branch residing in Kuvempunagar
void listStudentsByBranchAndAddress(char *branch, char *address) {
    FILE *infile;
    struct Student student;

    infile = fopen("students.txt", "r");
    if (infile == NULL) {
        printf("Error opening file.\n");
        return;
    }

    while (fscanf(infile, "%d %s %s %d %s", &student.SID, student.NAME, student.BRANCH, &student.SEMESTER, student.ADDRESS) != EOF) {
        if (strcmp(student.BRANCH, branch) == 0 && strcmp(student.ADDRESS, address) == 0) {
            printf("SID: %d, Name: %s, Branch: %s, Semester: %d, Address: %s\n", student.SID, student.NAME, student.BRANCH, student.SEMESTER, student.ADDRESS);
        }
    }

    fclose(infile);
}

int main() {
    int choice, sid;
    char branch[50], address[100];

    while (1) {
        printf("\nMenu:\n");
        printf("1. Insert a new student\n");
        printf("2. Modify student's address\n");
        printf("3. Delete a student\n");
        printf("4. List all students\n");
        printf("5. List all students of a specific branch\n");
        printf("6. List all students of a specific branch residing in Kuvempunagar\n");
        printf("7. Exit\n");
        printf("Enter your choice: ");
        scanf("%d", &choice);

        switch (choice) {
            case 1:
                insertStudent();
                break;
            case 2:
                printf("Enter SID to modify address: ");
                scanf("%d", &sid);
                modifyAddress(sid);
                break;
            case 3:
                printf("Enter SID to delete: ");
                scanf("%d", &sid);
                deleteStudent(sid);
                break;
            case 4:
                listAllStudents();
                break;
            case 5:
                printf("Enter branch to list students: ");
                scanf("%s", branch);
                listStudentsByBranch(branch);
                break;
            case 6:
                printf("Enter branch: ");
                scanf("%s", branch);
                printf("Enter address: ");
                scanf("%s", address);
                listStudentsByBranchAndAddress(branch, address);
                break;
            case 7:
                return 0;
            default:
                printf("Invalid choice. Try again.\n");
        }
    }

    return 0;
}

// Good afternoon to everyone present here, and to everyone watching the live stream.
// We're from the Google Developers Student Club. 
// (introduce yourselves, tell your name)

// Welcome to the world of Google developers. All of you must have use some sort of Google technology, regardless of which branch you're in.
// So what is it that we do? We help bridge the gap between technology and actual learning i.e. practical learning. We do this through peer-to-peer and community learning. Our main goal is to give back to the community. The community has given us so much, so Google stresses on contributing back to it. Another major thing about us is that we focus on inclusivity. So regardless of which branch you're in or what stage of learning or coding you're in,you're always welcome in our community.

// (2nd person take over)

// So it turns out, GDSC JSSSTU is one of only 2 GDSC chapters in Asia to have conducted a workshop for specially abled students. It involved the students from the Polytechnic on campus. They learned the fundamentals of Android Studio and walked home with an application built by themselves installed on their smartphones.

// Another important event we've been conducting every year is the Explore ML workshop, where we give the participants an intro to the booming world of Machine Learning, Deep Learning and Artificial Intelligence. 
// Here's a picture of the workshop we had back in April. (gesture to the PPT)

// We also conduct many campaigns to help students enter into Android, Flutter, Web Dev, etc. We also conduct non-technical and fun events. We have GDSC Elevate where the focus is on soft skills like communication, resume building, networking, using LinkedIn, etc.

// (team pic) This was the core team of the club for the term 2022-23. We have a new team now, for this term of 2023-24, as our recruitment got over recently.

// (last slide) So to know more about us, do visit our Instagram, LinkedIn and Twitter. We also have a Discord server. You can access them on this link or scan the QR code as well.

// We hope to see you at our future events, to connect, learn, grow and have fun as well! Thank you.
