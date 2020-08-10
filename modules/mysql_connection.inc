new MySQL: mysql;

new mysql_host 	   [50],
	mysql_username [50],
 	mysql_password [50],
 	mysql_database [50];

stock ConnectToDatabase ()
{
	if (!fexist (MYSQL_DETAILS_FILE))
	{
 		printf ("[MYSQL] ERROR: MYSQL_DETAILS_FILE not found.");
 		printf ("[MYSQL] Creating MYSQL file. ", MYSQL_DETAILS_FILE);

 		new INI: temp = INI_Open (MYSQL_DETAILS_FILE);
 		INI_WriteString (temp, "MYSQL_HOST", "");
 		INI_WriteString (temp, "MYSQL_USERNAME", "");
		INI_WriteString (temp, "MYSQL_PASSWORD", "");
		INI_WriteString (temp, "MYSQL_DATABASE", "");
 		INI_Close (temp);

 		printf ("[MYSQL] MYSQL file created at: \"%s\"", MYSQL_DETAILS_FILE);
 		printf ("[MYSQL] Enter the MYSQL details in the file and restart the server. ");
 		printf ("[MYSQL] Shutting down the server. ");

 		SendRconCommand ("exit");

		return 0;
	}

	INI_ParseFile (MYSQL_DETAILS_FILE, "GetMYSQLDetails");

	mysql = mysql_connect (mysql_host, mysql_username, mysql_password, mysql_database);

	if (mysql_errno () == 0) { printf ("[MYSQL] Successfully connected to the database. \n"); }
	else 					 { printf ("[MYSQL] Failed to connect to the database. \n"); }

	return 1;
}

forward GetMYSQLDetails (name[], value[]);
public GetMYSQLDetails (name[], value[])
{
	INI_String ("MYSQL_HOST", mysql_host);
	INI_String ("MYSQL_USERNAME", mysql_username);
	INI_String ("MYSQL_PASSWORD", mysql_password);
	INI_String ("MYSQL_DATABASE", mysql_database);
	return 1;
}
