# Appwrite Dart SDK Bug Demonstration

This project demonstrates a bug in the Appwrite Dart SDK where the IO client strips null values from request parameters, but the API endpoint requires the `default` parameter to be explicitly provided.

## The Bug

### Issue Description

When attempting to update a string column attribute using `TablesDB.updateStringColumn()` with `xdefault: null`, the request fails with the following error:

```
AppwriteException: general_argument_invalid, Param "default" is not optional. (400)
```

### Root Cause

The Appwrite Dart SDK's IO client (`ClientIO`) automatically removes `null` values from request parameters before sending them to the API. However, the Appwrite API endpoint for `updateStringColumn` requires the `default` parameter to be explicitly included in the request, even when setting it to `null` to remove a default value.

This creates a conflict:
- The SDK removes `null` values (thinking they're optional parameters)
- The API endpoint requires the parameter to be present (to explicitly clear the default value)

### Error Location

The error occurs in `TablesDB.updateStringColumn()` at line 44-50 of `bin/appwrite_sdk_issue_example.dart`:

```dart
final updatedColumn = await tablesDB.updateStringColumn(
  databaseId: database.$id,
  tableId: table.$id,
  key: column.key,
  xrequired: false,
  xdefault: null,  // <-- This null is stripped by the client, but required by the API
);
```

## Step-by-Step Guide to Reproduce

### Prerequisites

1. **Dart SDK**: Ensure you have Dart SDK installed (version 3.7.2 or higher)
2. **Appwrite Instance**: You need access to an Appwrite cloud instance or self-hosted instance
3. **API Key**: Generate an API key in your Appwrite project with databases, tables and columns scope

### Setup Instructions

1. **Clone or download this repository**

2. **Update configuration** in `bin/appwrite_sdk_issue_example.dart`:
   - Replace `projectId` with your Appwrite project ID
   - Replace `endpoint` with your Appwrite endpoint (if different)
   - Replace `apiKey` with your Appwrite API key

3. **Install dependencies**:
   ```bash
   dart pub get
   ```

4. **Run the example**:
   ```bash
   dart run bin/appwrite_sdk_issue_example.dart
   ```

### Expected Behavior

The script will successfully:
1. ✅ Create a new database
2. ✅ Create a new table within the database
3. ✅ Add a required string column to the table
4. ❌ **Fail** when attempting to update the column to be optional without a default value

The error will occur at step 4, with the message:
```
Error: AppwriteException: general_argument_invalid, Param "default" is not optional. (400)
```

## Implications

### For Developers

1. **Workaround Required**: Developers cannot currently remove default values from string columns using the Dart SDK's `updateStringColumn` method without encountering this error.

2. **Inconsistent Behavior**: The SDK's null-stripping behavior works for optional parameters but breaks for required parameters that accept null values.

3. **API Contract Mismatch**: There's a mismatch between:
   - What the SDK considers optional (null = omit parameter)
   - What the API considers required (parameter must be present, even if null)

### For Appwrite SDK Maintainers

1. **ClientIO Null Handling**: The `ClientIO` class (or `ClientMixin`) should be updated to:
   - Detect when a parameter is required by the endpoint
   - Send `null` values explicitly instead of stripping them
   - Or provide a way to mark parameters as "required even if null"

2. **Method Signature Consideration**: The `updateStringColumn` method should either:
   - Use an optional nullable parameter (`xdefault` nullable) and handle the null case properly
   - Document that you cannot remove default values via this method
   - Provide a separate method or parameter to explicitly clear defaults

3. **API Documentation**: The API documentation should clarify whether `default` is required when updating attributes, and if `null` is a valid value to explicitly clear defaults.

### Potential Solutions

1. **SDK Fix**: Modify the client to include `null` values for required parameters
2. **API Fix**: Make the `default` parameter optional when not changing it
3. **Documentation**: Clarify the expected behavior and provide a workaround

## Files

- `bin/appwrite_sdk_issue_example.dart` - The demonstration script
- `pubspec.yaml` - Project dependencies (uses `dart_appwrite: ^19.2.1`)

## Related Issues

This bug affects any operation where:
- An API endpoint requires a parameter to be present
- The parameter can accept `null` as a valid value (to clear/reset something)
- The SDK automatically strips `null` values

## Technical Details

- **SDK Version**: dart_appwrite 19.2.1
- **Error Type**: `AppwriteException: general_argument_invalid`
- **HTTP Status**: 400 Bad Request
- **Error Location**: `TablesDB.updateStringColumn()` when `xdefault: null`
