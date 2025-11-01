import 'package:dart_appwrite/dart_appwrite.dart';

// Configuration - update these values with your Appwrite credentials
const String projectId = 'YOUR_PROJECT_ID';
const String endpoint = 'https://cloud.appwrite.io/v1';
const String apiKey = 'YOUR_API_KEY';

void main(List<String> arguments) async {
  // Initialize the Appwrite client
  final client =
      Client()
        ..setEndpoint(endpoint)
        ..setProject(projectId)
        ..setKey(apiKey);

  // Initialize the TablesDB service
  final tablesDB = TablesDB(client);

  try {
    // Step 1: Create a new database
    print('Creating database...');
    final database = await tablesDB.create(databaseId: ID.unique(), name: 'ExampleDatabase');
    print('Database created: ${database.$id}');

    // Step 2: Create a new table within the database
    print('Creating table...');
    final table = await tablesDB.createTable(databaseId: database.$id, tableId: ID.unique(), name: 'ExampleTable');
    print('Table created: ${table.$id}');

    // Step 3: Add a required string column to the table
    print('Creating required column...');
    final column = await tablesDB.createStringColumn(
      databaseId: database.$id,
      tableId: table.$id,
      key: 'exampleColumn',
      size: 255,
      xrequired: true,
    );
    print('Column created: ${column.key} (Required: ${column.xrequired})');

    // Step 4: Update the column to be optional without a default value
    print('Updating column to optional...');
    final updatedColumn = await tablesDB.updateStringColumn(
      databaseId: database.$id,
      tableId: table.$id,
      key: column.key,
      xrequired: false,
      xdefault: null,
    );
    print(
      'Column updated: ${updatedColumn.key} (Required: ${updatedColumn.xrequired}, Default: ${updatedColumn.xdefault})',
    );

    print('\nAll operations completed successfully!');
  } catch (e) {
    print('Error: $e');
    rethrow;
  }
}
