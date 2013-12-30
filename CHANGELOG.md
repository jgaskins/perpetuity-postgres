## Version 0.0.2

- Make DB creation call out to remote DB to create it instead of calling on localhost.
- Add index support
- Only load UUID extension on UUID failure. This keeps the DB log from getting flooded every time the app connects to it.
- Add support for any?/none? on query attributes for queries like `mapper.select { |user| user.friends.any? }`
- Serialize nil values in JSONHash
- Add support for in-place increment/decrement. This allows you to use a mapper's `#increment`/`#decrement` methods to modify the object without pulling it down from the DB first.
- Keep first value when inserting multiple records. This fixes a bug where a `SerializedData` value (the data structure holding what's being inserted) would modify itself in place on `each` calls.
- Cast numeric ids to numeric types on insertion. Previously, if you had an `Integer` id column, it was being returned as a string.
- Don't allow double quotes in table names. Postgres doesn't allow it, so this catches it before we have to make the DB call.
- Add support for more numeric types
- Escape double quotes in JSON strings
- Add table columns automatically if they don't exist. This way, you can simply add more attributes in your mapper and Perpetuity::Postgres will take care of it on its own.

## Version 0.0.1

- Initial release.
- Most Perpetuity CRUD features enabled.
