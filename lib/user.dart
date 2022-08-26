import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:grpc/grpc.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:protobuf/protobuf.dart';
import 'package:app_server/src/generated/users.pbgrpc.dart';

import 'mongo_database.dart';

class UserService extends UserServiceBase {
  Future<DbCollection> getUsersCollection() async {
    Db db = await MongoDatabase().getConnection();

    return db.collection('users');
  }

  Digest hashPassword(String userId, password) {
    var saltedPassword = userId + password;
    var bytes = utf8.encode(saltedPassword);

    return sha512.convert(bytes);
  }

  @override
  Future<CreateUserReply> createUser(
      ServiceCall call, CreateUserRequest request) async {
    final userId = Uuid().v4();
    final firstName = request.user.firstName;
    final lastName = request.user.lastName;
    final addressLine1 = request.user.addressLine1;
    final addressLine2 = request.user.addressLine2;
    final city = request.user.city;
    final state = request.user.state;
    final zipCode = request.user.zipCode;
    final phoneNumber = request.user.phoneNumber;
    final email = request.user.email;
    final password = request.user.password;
    final usersCollection = await getUsersCollection();

    final result = await usersCollection.insertOne({
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'user_id': userId,
      'address_line_1': addressLine1,
      'address_line_2': addressLine2,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'phone_number': phoneNumber,
      'hash': hashPassword(userId, password).toString(),
      'is_disabled': false,
      'created_datetime': DateTime.now(),
      'modified_datetime': DateTime.now(),
    });

    await MongoDatabase().close();

    if (result.isFailure) {
      throw ErrorInfo()
        ..reason = 'Cannot create user. ${result.writeError!.errmsg}';
    }

    return CreateUserReply()
      ..userId = userId
      ..success = true;
  }

  @override
  Future<LoginUserReply> loginUser(
      ServiceCall call, LoginUserRequest request) async {
    final login = request.login;
    final password = request.password;
    final usersCollection = await getUsersCollection();
    final result = await usersCollection.findOne({'email': login});

    await MongoDatabase().close();

    if (result == null || result.isEmpty) {
      throw ErrorInfo()..reason = 'Cannot find user.';
    }

    if (hashPassword(result['user_id'], password).toString() !=
        result['hash']) {
      throw ErrorInfo()..reason = 'Password invalid.';
    }

    if (result['is_disabled']) {
      throw ErrorInfo()..reason = 'Account is disabled.';
    }

    return LoginUserReply()
      ..success = true
      ..user = User(
        userId: result['user_id'],
        email: result['email'],
        firstName: result['first_name'],
        lastName: result['last_name'],
        addressLine1: result['address_line_1'],
        addressLine2: result['address_line_2'],
        city: result['city'],
        state: result['state'],
        zipCode: result['zip_code'],
        phoneNumber: result['phone_number'],
        createdDatetime: parseLongInt(
            result['created_datetime'].millisecondsSinceEpoch
                .toString()),
        modifiedDatetime: parseLongInt(
            result['modified_datetime'].millisecondsSinceEpoch
                .toString()),
        disabledDatetime: parseLongInt(
            result['disabled_datetime']?.millisecondsSinceEpoch
                .toString() ?? '0'),
      );
  }

  @override
  Future<ReadUserReply> readUser(ServiceCall call, ReadUserRequest request) {
    // TODO: implement readUser
    throw UnimplementedError();
  }

  @override
  Future<ReadUsersReply> readUsers(ServiceCall call, ReadUsersRequest request) {
    // TODO: implement readUsers
    throw UnimplementedError();
  }

  @override
  Future<UpdateUserReply> updateUser(
      ServiceCall call, UpdateUserRequest request) {
    // TODO: implement updateUser
    throw UnimplementedError();
  }

  @override
  Future<DisableUserReply> disableUser(
      ServiceCall call, DisableUserRequest request) async {
    final userId = request.userId;
    final usersCollection = await getUsersCollection();
    final result = await usersCollection.updateOne(
        where.eq('user_id', userId),
        ModifierBuilder()
            .set('is_disabled', true)
            .set('disabled_datetime', DateTime.now().toString()));

    if (result.isFailure) {
      throw ErrorInfo()
        ..reason = 'Unable to disable user. ${result.writeError!.errmsg}';
    }

    return DisableUserReply()..success = true;
  }

  @override
  Future<EnableUserReply> enableUser(
      ServiceCall call, EnableUserRequest request) async {
    final userId = request.userId;
    final usersCollection = await getUsersCollection();
    final result = await usersCollection.updateOne(
        where.eq('user_id', userId),
        ModifierBuilder()
            .set('is_disabled', false)
            .set('modified_datetime', DateTime.now().toString()));

    if (result.isFailure) {
      throw ErrorInfo()
        ..reason = 'Unable to enable user. ${result.writeError!.errmsg}';
    }

    return EnableUserReply()..success = true;
  }
}
