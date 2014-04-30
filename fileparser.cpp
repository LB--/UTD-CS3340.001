#include<iostream>
#include <fstream>
#include <string>
#include <vector>
#include <time.h>
#include<cstdlib>
#include<cstdio>
using namespace std;

vector<string>fileContents(int);
string pickAlphabets(int);
int main()
{

	cout << "Choose the number of characters (n) to play with 5,6 or 7 " << endl;
	vector<string> results;
	int userInput;
	string randomLetters;
	cin >> userInput;
	randomLetters = pickAlphabets(userInput);
	cout << "Random letters are " << randomLetters << "\n" << endl;
	results = fileContents(userInput);
	for (int i = 0; i < results.size(); i++)
	{
		if (results[i].length() <= userInput)
		{
			cout << results[i] << endl;
		}
	}



}

std::vector<std::string> fileContents(int num)
{
	string line;
	vector<string> contents;
	ifstream myfile("dictionary.txt");
	if (myfile.is_open())
	{
		while (getline(myfile, line))
		{

			for (int i = 0; i < 1; i++)
			{
				contents.push_back(line);
			}
		}
		myfile.close();
	}
	else
		cout << "Unable to open file";

	return contents;
}

string  pickAlphabets(int num)
{
	srand(time(0));
	string alphabet;
	string randomLetters;
	for (int i = 0; i < 26; ++i) {
		alphabet.push_back('A' + i);
	}
	int r;
	char temp;
	for (int i = 0; i < 6; ++i) {
		r = rand() % 26;
		temp = alphabet[i];
		alphabet[i] = alphabet[r];
		alphabet[r] = temp;

	}
	for (int i = 0; i < num; i++)
	{
		if (num > 7){
			printf("Number must be between 5 and 7 \n");
			exit(EXIT_FAILURE);
		}

		else
			randomLetters += alphabet[i];

	}
	return randomLetters;
}
