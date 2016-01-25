//
//  ViewController.m
//  复习core data12－16
//
//  Created by dc004 on 15/12/16.
//  Copyright © 2015年 gang. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"//引入需要使用的实体
#import <CoreData/CoreData.h>
@interface ViewController ()
{
    //管理对象上下文
    NSManagedObjectContext *_context;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _context = [self createDBContext];
//    [self addPersonWithName:@"coco" sex:@"男" age:@22];
//    [self addPersonWithName:@"Ax" sex:@"女" age:@22];
    NSLog(@"%@",[[self getPersonByName:@"Ax"]valueForKey:@"name"]);
//    [self getPersonByName:@"coco"];
//    [self removePerson:@"coco"];
    [self modifyPersonWithName:@"Ax" sex:@"女" age:@90];


}
#pragma mark 1.创建管理上下文
-(NSManagedObjectContext *)createDBContext{
    NSManagedObjectContext *context;
    //打开模型文件，参数为nil则打开包中所有模型文件并合并成一个
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
//    NSLog(@"%@",model);
    //创建解析器 NSPersistentStoreCoordinator
    NSPersistentStoreCoordinator *storeCoordinator = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:model];
    //创建数据库保存路径(文件目录)
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)firstObject];
    path = [path stringByAppendingPathComponent:@"WK.db"];
    //添加SQLite持久存储到解析器
    NSError *error;
    [storeCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:path] options:nil error:&error];
    if (error) {
        NSLog(@"数据库打开失败原因是:%@",error.localizedDescription);
    }
    else{//数据库创建成功（打开成功）
        context = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSMainQueueConcurrencyType];
        context.persistentStoreCoordinator = storeCoordinator;
        NSLog(@"数据库打开成功");
        NSLog(@"%@",path);
        
    }
    return context;
}
#pragma mark 2.插入数据
-(void)addPersonWithName:(NSString*)name sex:(NSString*)sex age:(NSNumber*)age{
    //创建实体对象
    Person *person = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:_context];
    person.name = name;
    person.age = age;
    person.sex = sex;
    //保存上下文
    NSError *error;
    [_context save:&error];
    if (error) {
        NSLog(@"添加过程中发送错误，原因是%@",error.localizedDescription);
    }
    else {
        NSLog(@"success");
    }
}
#pragma mark 3.查询数据
//NSPredicate(谓词)是一个Foundtion的类，它指定数据被获取或者过滤的方式。它的语言就像SQL的where和正则表达式的交叉一样。提供了具有表现力的自然语言界面来定义一个集合。(被搜索的逻辑条件)
-(NSArray*)getPersonByName:(NSString*)name{
    //创建一个请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    request.predicate = [NSPredicate predicateWithFormat:@"%K=%@",@"name",name];
    //上下文执行请求，得到查询结果
    NSArray *array = [_context executeFetchRequest:request error:nil];
    
    return array;
}
#pragma mark 4.删除数据
-(void)removePerson:(NSString *)name{
    Person *person = [[self getPersonByName:name]firstObject];
    [_context deleteObject:person];
    NSError *error;
    [_context save:&error];
    if (error) {
        NSLog(@"删除过程中发生错误，原因是:%@",error.localizedDescription);
    }else{
        NSLog(@"删除成功");
    }
}
#pragma mark 修改数据
//必须首先提取出对应的实体对象，然后通过修改对象属性，最后保存
-(void)modifyPersonWithName:(NSString*)name sex:(NSString*)sex age:(NSNumber*)age{
    Person *person = [[self getPersonByName:name]firstObject];
    person.sex = sex;
    person.age = age;
    NSError *error;
    [_context save:&error];
    if (error) {
        NSLog(@"修改过程中发生错误，原因是:%@",error.localizedDescription);
    }else{
        NSLog(@"修改成功");
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
