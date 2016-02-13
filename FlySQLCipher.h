//
//  FlySQLCipher.h
//  FlySQLCipher
//
//  Created by 李飞翔 on 15/8/1.
//  Copyright (c) 2015年 Fly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
@interface FlySQLCipher : NSObject

/**
 打开或者创建一个加密数据库（key为密码）
 */
+(sqlite3*)FlyOpenSQLCipherPath:(NSString*)dbPath dbName:(NSString*)dbName Key:(NSString*)Key;
/**
 创建table 表名 字段名数组
 */
+(int)FlyCreateTabDB:(sqlite3 *)db tableName:(NSString*)tableName columns:(NSArray*)columns primaryKey:(NSString*)keyName;
/**
 增加数据，columns为字段名数组，fields为字段数组
 */
+(int)FlyAddDB:(sqlite3 *)db tableName:(NSString*)tableName columns:(NSArray*)columns Fields:(NSArray*)fields;
/**
 查找数据  condition格式为 @"heroName=zhangsan and age=999" condition写nil为无条件查找
 */
+ (NSMutableArray*)FlyQueryDB:(sqlite3 *)db tableName:(NSString*)tableName Condition:(NSString*)condition ;
/**
 删除数据  condition格式为 @"heroName=zhangsan and age=999"
 */
+(int)FlyDeleteDB:(sqlite3 *)db tableName:(NSString*)tableName Condition:(NSString*)condition;
/**
 删除表
 */
+(int)FlyDropDB:(sqlite3 *)db tableName:(NSString*)tableName ;
/**
 关闭数据库
 */
+(void)FlyCloseDB:(sqlite3*)db;
/**修改数据库
 */
+(int)FlyChangeDB:(sqlite3 *)db tableName:(NSString*)tableName changeColumn:(NSString*)column ForColumn:(NSString*)field;







@end
