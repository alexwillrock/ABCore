//
//  ABAPIClient.h

#import "MKNetworkKit.h"
#import "ABAPIDefinitions.h"
#import "ABAPIObjects.h"
#import "ABRequest.h"
#import "ABParseResponseHandler.h"

extern NSString *const ABAPIClientMethodGET;
extern NSString *const ABAPIClientMethodPOST;

@protocol ABAPIClientCustomization <NSObject>

@required
+ (NSString *)domainName;
+ (NSString *)domainPath;

@optional
- (NSString *)sessionId;

- (NSDictionary *)additionalCommonParameters;

- (NSArray *)resultCodesSuccess;
- (NSArray *)resultCodesNeedProcessing;

@end


@interface ABAPIClient : MKNetworkEngine <ABParseResponseHandlerDelegate, ABAPIClientCustomization>

@property (nonatomic, readonly) NSMutableArray * arrayOfOperationsToEnqueue;

@property (nonatomic, strong) NSMutableArray * balanceAffectingAPIMethods;



+ (id)sharedInstance;




#pragma mark -
#pragma mark - Response parsing

/**
 Метод вызывается в случае получения ответа от сервера. Нуждается в переопределении у наследников для описания логики реакции.
 */
- (void)parseJSONResponse:(id)responseObject
				onSuccess:(void(^)())success
				   onFail:(void(^)(ABError * error))fail;




#pragma mark -
#pragma mark - Requests Queueing

/**
 Метод, внутри которого должны определяться критерии добавления блока создания запроса в очередь (например, если пользователь не авторизован(или протухла сессия), но успел отправить запрос требующий валидной сессии).
 По умолчанию метод возвращает NO.
 */
- (BOOL)shouldKeepRequestCreationBlockInQueueCondition;

/**
 Выполняет все блоки, находящиеся в очереди.
 */
- (void)performBlocksInQueue;




#pragma mark -
#pragma mark - Create operation

- (MKNetworkOperation *)parsedOperationWithPath:(NSString *)path
										 params:(NSDictionary *)body
									 httpMethod:(NSString *)method
							parametersInjection:(BOOL)shouldInject
								   addSessionId:(BOOL)addSessionId
								   onCompletion:(void (^)(MKNetworkOperation * operation, id responseObject, NSError * error))onCompletionBlock;

- (MKNetworkOperation *)parsedOperationWithPath:(NSString *)path
										 params:(NSDictionary *)body
									 httpMethod:(NSString *)method
							parametersInjection:(BOOL)shouldInject
								   addSessionId:(BOOL)addSessionId
								   successBlock:(void (^)(MKNetworkOperation * operation, id responseObject))onSuccess
								   failureBlock:(void (^)(MKNetworkOperation * operation, ABError * error))onFail;




#pragma mark -
#pragma mark - Create request (automatically enqueue operation)

- (void)path:(NSString *)path
  withMethod:(NSString *)method
  parameters:(NSDictionary *)parameters
parametersInjection:(BOOL)shouldInject
addSessionId:(BOOL)addSessionId
	 success:(void (^)(MKNetworkOperation * completedOperation, id responseObject))success
	 failure:(void (^)(MKNetworkOperation * completedOperation, ABError *error))failure;

- (void)path:(NSString *)path
  withMethod:(NSString *)method
  parameters:(NSDictionary *)parameters
  parametersInjection:(BOOL)shouldInject
		 addSessionId:(BOOL)addSessionId
		 onCompletion:(void (^)(MKNetworkOperation * completedOperation, id responseObject, NSError * error))onCompletionBlock;




#pragma mark -
#pragma mark - Helpers

+ (NSString *)messageFromError:(NSError *)error;
+ (void)printLog:(MKNetworkOperation *)operation;
+ (ABError *)appzavrErrorFromError:(NSError *)error;
+ (ABError *)tcsErrorWithMessage:(NSString *)message;

@end
