// windows-event-log-assistant.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

/*
Basic functionality of the PowerShell version:
-Filters a given severity level of messages for a given number of days of history and writes to a given file name
-Appears to use a HashTable to filter logname, level, and StartTime
-Has a very basic nested for loop to search every entry against every other entry, until a match is found. O(n*n), maybe O(n*n*n) due to text matching worst case (no matches)
-Missing features:
--Keep track of how many duplicates exist for a given entry description
--Highlight common actual-problem entries
--Deprioritize common not-a-problem entries in the list
--Save-and-clear event logs
--Run remotely, get results locally


Accessing event log appears to be C-style bindings:
https://learn.microsoft.com/en-us/windows/win32/eventlog/reading-from-the-event-log
https://learn.microsoft.com/en-us/windows/win32/eventlog/querying-for-event-source-messages

Run a PowerShell inside C++ and gain access to raw data from it
https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.powershell?view=powershellsdk-7.4.0&redirectedfrom=MSDN

MS Base Types: https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-dtyp/3caa4769-b02f-4cee-a857-8496f4395ec1
MS-DTYPE https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-dtyp/efda8314-6e41-4837-8299-38ba0ee04b92
*/


#include <iostream>

int main()
{
    
}

