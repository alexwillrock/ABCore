
#import "ABSingleton.h"
#include <string.h>
#include <objc/runtime.h>

static void swizzleMethods(Class selfClass, Class singletonClass, SEL originalSelector, SEL backupSelector);

static Method class_getCurrentClassMethod(Class class, SEL name);

@implementation ABSingleton

static NSMutableDictionary* _children;

+ (void)initialize //thread-safe
{
    if (!_children) {
        _children = [[NSMutableDictionary alloc] init];
    }
    [_children setObject:[[self alloc] init] forKey:NSStringFromClass(self.class)];
}

+ (instancetype)alloc
{
    id child = [self instance];
    return child ? child : [self allocWithZone:nil];
}

- (instancetype)init
{
    id result = [_children objectForKey:NSStringFromClass(self.class)];
    if (result == nil) {
        self = [super init];
        result = self;
        if (result && ![super isMemberOfClass:[NSObject class]] && ![self isMemberOfClass:[ABSingleton class]]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wselector"
#pragma clang diagnostic ignored "-Wundeclared-selector"
            swizzleMethods(self.class, [ABSingleton class], @selector(init), @selector(initBackup_tcs_));
#pragma clang diagnostic pop
        }
    }
    return result;
}

+ (instancetype)instance
{
    return [_children objectForKey:NSStringFromClass(self.class)];
}

+ (instancetype)defaultInstance
{
    return [self instance];
}

+ (instancetype)sharedInstance
{
    return [self instance];
}

+ (instancetype)singleton
{
    return [self instance];
}

+ (instancetype)new
{
    return [self instance];
}

+ (instancetype)copyWithZone:(NSZone *)zone
{
    return [self instance];
}

+ (instancetype)mutableCopyWithZone:(NSZone *)zone
{
    return [self instance];
}

@end

#pragma mark -
#pragma mark - utitlity funcations

void swizzleMethods(Class selfClass, Class singletonClass, SEL originalSelector, SEL backupSelector) {
    unsigned int classesCount = 2;
    Method *swizzledMethods = calloc(classesCount, sizeof(Method));
    {
        Class classes[2] = {selfClass, singletonClass};
        
        for (unsigned int i = 0; i < classesCount; i++) {
            swizzledMethods[i] = class_getCurrentClassMethod(classes[i], originalSelector);
        }
    }
    Method selfMethod = swizzledMethods[0];
    Method singletonMethod = swizzledMethods[1];
    
    free(swizzledMethods);
    swizzledMethods = NULL;
    
    IMP singletonMethodIMP = method_getImplementation(singletonMethod);
    const char * const singletonMethodTypeEncoding = method_getTypeEncoding(singletonMethod);
    IMP originalMethodIMP = method_getImplementation(selfMethod);
    if (selfMethod) {
        class_replaceMethod(selfClass, originalSelector, singletonMethodIMP, singletonMethodTypeEncoding);
        if (backupSelector != nil) {
            class_addMethod(selfClass, backupSelector, originalMethodIMP, method_getTypeEncoding(selfMethod));
        }
    }
}

Method class_getCurrentClassMethod(Class class, SEL name) {
    Method *methodList = NULL;
    unsigned int methodListCount = 0;
    
    methodList = class_copyMethodList(class, &methodListCount);
    assert(methodListCount > 0);
    unsigned int j = 0;
    for (; name != method_getName(methodList[j]) && j < methodListCount; j++);
    
    Method result = NULL;
    if (j < methodListCount) {
        result = methodList[j];
    }
    
    free(methodList);
    methodList = NULL;
    methodListCount = 0;
    
    return result;
}
