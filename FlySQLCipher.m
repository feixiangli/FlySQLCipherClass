//
//  FlySQLCipher.m
//  FlySQLCipher
//
//  Created by 李飞翔 on 15/8/1.
//  Copyright (c) 2015年 Fly. All rights reserved.
//

#import "FlySQLCipher.h"
#import "UserModel.h"
#import "CartModel.h"
#import "CartDetailModel.h"

@implementation FlySQLCipher

+(sqlite3*)FlyOpenSQLCipherPath:(NSString*)dbPath dbName:(NSString*)dbName Key:(NSString*)Key
{
        //数据库地址，数据库名
        dbPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",dbName]];
         sqlite3 *db;
        //打开数据库
        if (sqlite3_open([dbPath UTF8String], &db) == SQLITE_OK)
        {
            NSLog(@"1.正在打开数据库：%@ 状态：成功",dbName);
            const char* key = [Key UTF8String];
            NSLog(@"2.设置密码为:%s",key);
            //输入密码，必须输入密码。然后才能对数据库操作
            sqlite3_key(db, key,(int)(strlen(key)));
            //  参数：数据库名，密码，密码长度
            /*
             sqlite3_exec
             参数:
             一个打开的数据库
             SQL进行评估
             回调函数
             第一参数回调
             错误信息写在这里*
             */
            int result = sqlite3_exec(db, (const char*) "SELECT count(*) FROM sqlite_master;", NULL, NULL, NULL);
            if (result == SQLITE_OK)
            {
                NSLog(@"3.验证密码：%s 密码正确！",key);
            }
            else
            {
                NSLog(@"密码错误! errCode:%d",result);
            }
        }else
        {
            NSLog(@"打开DB失败！数据库不存在");
        }
        NSLog(@"4.%@数据库地址:%@",dbName,NSHomeDirectory());
    
    return db;
}

+(int)FlyCreateTabDB:(sqlite3 *)db tableName:(NSString*)tableName columns:(NSArray*)columns primaryKey:(NSString*)keyName
{
    NSString*stringColumn=[columns componentsJoinedByString:@","];
    NSString * stringSql=[NSString stringWithFormat:@"create table %@(%@,PRIMARY KEY (%@));",tableName,stringColumn,keyName];
    const char * sql=[stringSql UTF8String];
    int result = sqlite3_exec(db, sql , NULL, NULL, NULL);
    if(result==1)
    {
        NSLog(@"5.创建表--状态:失败（表已存在）");
    }
    else
    {
        NSLog(@"5.创建表--状态:成功");
    }

    return result;
}
+(int)FlyAddDB:(sqlite3 *)db tableName:(NSString*)tableName columns:(NSArray*)columns Fields:(NSArray*)fields
{
    NSString*stringColumn=[columns componentsJoinedByString:@","];
    NSMutableArray *tfields = [[NSMutableArray alloc] initWithCapacity:0] ;
    for (NSObject *fid in fields) {
        if ([fid isEqual:@""]) {
            [tfields addObject:@"''"] ;
        }else{
            [tfields addObject:[NSString stringWithFormat:@"'%@'",fid]] ;
        }
    }
    NSString*stringField=[tfields componentsJoinedByString:@","];
    
    NSString * stringSql=[NSString stringWithFormat:@"replace into %@(%@) values (%@);",tableName,stringColumn,stringField];
    const char * sql=[stringSql UTF8String];
    char *errmsg ;
    int result = sqlite3_exec(db, sql, NULL, NULL, &errmsg);
    if(result==1)
    {
        NSString *strErrMsg = [NSString stringWithUTF8String:errmsg];
        NSLog(@"%@",strErrMsg) ;
        NSLog(@"6.添加数据--状态:失败");
    }
    else
    {
        NSLog(@"6.添加数据--状态:成功");
    }
    return result;
}
+ (NSMutableArray*)FlyQueryDB:(sqlite3 *)db tableName:(NSString*)tableName Condition:(NSString*)condition
{
    NSMutableArray *strList = [NSMutableArray arrayWithCapacity:0];

    NSLog(@"7.打印数据库内容");
    if(condition)
    {
        NSString * stringSql=[NSString stringWithFormat:@"select * from %@ where %@;",tableName,condition];
        const char * sql=[stringSql UTF8String];
        int result = sqlite3_exec(db, sql, callback, (__bridge void *)(strList), NULL);
        
        if(result==1)
        {
            NSLog(@"8.查找数据--状态:失败");
        }
        else
        {
            NSLog(@"8.查找数据--状态:成功");
        }
        return strList;
    }
    else
    {
        NSString * stringSql=[NSString stringWithFormat:@"select * from %@;",tableName];
        const char * sql=[stringSql UTF8String];
        int result = sqlite3_exec(db, sql, callback,(__bridge void *)(strList), NULL);
        if(result==1)
        {
            NSLog(@"8.查找数据--状态:失败");
        }
        else
        {
            NSLog(@"8.查找数据--状态:成功");
        }
        return strList;
    }
}

static int callback(void *NotUsed, int argc, char **argv, char **azColName){
    int i;
    NSMutableArray *arr=(__bridge NSMutableArray*)NotUsed;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0] ;
    for(i=0; i < argc; i++)
    {
        NSString*string=[NSString stringWithFormat:@"%s",azColName[i]];
        NSString*string2=[NSString stringWithFormat:@"%s",argv[i] ? argv[i] : "NULL"];
        [dict setObject:string2 forKey:string];
    }
    [arr addObject:dict] ;
    return 0;
}

+(int)FlyDeleteDB:(sqlite3 *)db tableName:(NSString*)tableName Condition:(NSString*)condition
{
    NSString * stringSql = @"" ;
    if (condition==nil) {
        stringSql=[NSString stringWithFormat:@"delete from %@ ;",tableName];
    }else{
        stringSql=[NSString stringWithFormat:@"delete from %@ where %@;",tableName,condition];
    }
    const char * sql=[stringSql UTF8String];
    int result = sqlite3_exec(db, sql, NULL, NULL, NULL);
    if(result==1)
    {
        NSLog(@"9.删除数据--状态:失败");
    }
    else
    {
        NSLog(@"9.删除数据--状态:成功");
    }
     return result;
}

+(int)FlyDropDB:(sqlite3 *)db tableName:(NSString*)tableName
{
    NSString * stringSql=[NSString stringWithFormat:@"DROP TABLE %@;",tableName];
    const char * sql=[stringSql UTF8String];
    int result = sqlite3_exec(db, sql, NULL, NULL, NULL);
    if(result==1)
    {
        NSLog(@"9.删除表--状态:失败");
    }
    else
    {
        NSLog(@"9.删除表--状态:成功");
    }
    return result;
}

+(void)FlyCloseDB:(sqlite3*)db
{
    int close=sqlite3_close(db);
    if(close==1)
    {
        NSLog(@"10.关闭数据--状态:失败");
    }
    else
    {
        NSLog(@"10.关闭数据--状态:成功");
    }
}
+(int)FlyChangeDB:(sqlite3 *)db tableName:(NSString*)tableName changeColumn:(NSString*)column ForColumn:(NSString*)field
{
    NSString * stringSql=[NSString stringWithFormat:@"update %@ set %@ where %@",tableName,column,field];
    const char * sql=[stringSql UTF8String];
    
    int result = sqlite3_exec(db, sql, NULL, NULL, NULL);
    if(result==1)
    {
        NSLog(@"11.修改数据--状态:失败");
    }
    else
    {
        NSLog(@"11.修改数据--状态:成功");
    }
    return result;
}

















@end
