db = connect('mongodb://localhost/iron');

db.users.createIndexes([{email: 1}, {user_id: 1}], {unique: true});