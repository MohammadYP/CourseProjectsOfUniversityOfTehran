#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

#define TOKEN_SIZE 10
#define PAWN   "pawn"
#define KNIGHT "knight"
#define ROOK   "rook"
#define QUEEN  "queen"
#define KING   "king"
#define MOVE_SIZE 7
const char CHESS_TOKEN[] = "CHESS";

char* createBlackToken(const char* name)
{
    if (name == NULL) return NULL;

    char* tokenHolder = (char*)malloc(TOKEN_SIZE);
    if (!tokenHolder) return NULL;

    srand(time(0));
    for (int i = 0; i < TOKEN_SIZE - 1; ++i)
    {
        tokenHolder[i] = rand() % 255;
    }
    tokenHolder[TOKEN_SIZE - 1] = '\0';

    return tokenHolder;
}


char* createWhiteToken(char* previousToken)
{

	char* currentToken = (char*)(malloc(sizeof(char) * TOKEN_SIZE));
	int i = 0;
	if (previousToken != NULL)
	{
		while (1)
		{
			if (i >= TOKEN_SIZE) {
				free(previousToken);
				return currentToken;
			}
			else if (i < strlen(CHESS_TOKEN))
				currentToken[i] = CHESS_TOKEN[i];
			else
				currentToken[i] = previousToken[i] + 1;
			i++;
		}
	}
	free(currentToken);
	free(previousToken);
	return NULL;
}

char* initFirstMove(char* whiteToken)
{
    if (whiteToken != NULL && strncmp(whiteToken, CHESS_TOKEN, strlen(CHESS_TOKEN)) != 0) {
        return whiteToken;
    }

    int choice;
    printf(
        "0: A King move\n"
        "1: A Queen move\n"
        "2: A Rook move\n"
        "3: A Knight move\n"
        "4: A Pawn move\n"
        "White's turn, enter the first move: ");
    scanf("%d", &choice);

    char* newToken = (char*)(malloc(sizeof(char) * MOVE_SIZE));
    if (newToken == NULL) {
        free(whiteToken);
        return NULL;
    }

    switch (choice)
    {
    case 0:
        strncpy(newToken, KING, MOVE_SIZE - 1);
        break;
    case 1:
        strncpy(newToken, QUEEN, MOVE_SIZE - 1);
        break;
    case 2:
        strncpy(newToken, ROOK, MOVE_SIZE - 1);
        break;
    case 3:
        strncpy(newToken, KNIGHT, MOVE_SIZE - 1);
        break;
    case 4:
        strncpy(newToken, PAWN, MOVE_SIZE - 1);
        break;
    default:
        free(newToken);
        return whiteToken;
    }
    newToken[MOVE_SIZE - 1] = '\0';

    free(whiteToken);
    return newToken;
}

int main(int argc, char* argv[])
{
    if (argc < 2)
    {
        fprintf(stderr, "Usage: %s <name>\n", argv[0]);
        return EXIT_FAILURE;
    }
	char* token = createBlackToken(argv[1]);
	printf("Token: %s\n", token);
	token = createWhiteToken(token);
	token = initFirstMove(token);
	printf("White's move: %s\n", token);
	free(token);
	return EXIT_SUCCESS;
}