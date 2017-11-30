//
//  ProjectDetailViewController.m
//  Skyapp 2
//
//  Created by Cheuk yu Yeung on 30/12/2016.
//  Copyright © 2016 Cheuk yu Yeung. All rights reserved.
//

#import "ProjectDetailViewController.h"
#import "Project.h"
#import "ProjectDetailTableViewCell.h"

@import Firebase;

static const int kSectionSend = 0;
static const int kSectionComments = 1;
static NSString *COMMANDPREFIX = @"skyappios:sendToPeers";

@interface ProjectDetailViewController (){
    NSIndexPath *_editingIndexPath;
}

@property (strong, nonatomic) NSMutableArray<FIRDataSnapshot *> *comments;
@property (strong, nonatomic) UITextField *commentField;
@property (strong, nonatomic) Project *project;
@property (strong, nonatomic) FIRDatabaseReference *projectRef;
@property (strong, nonatomic) FIRDatabaseReference *commentsRef;

@end

@implementation ProjectDetailViewController

FIRDatabaseHandle _refHandle;

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    FIRDatabaseReference *ref = [FIRDatabase database].reference;
    self.projectRef = [[ref child:@"projects"] child:_projectKey];
    self.commentsRef = [[ref child:@"project-comments"] child:_projectKey];
    [self.commentsRef keepSynced:YES];
    self.comments = [[NSMutableArray alloc] init];
    self.project = [[Project alloc] init];
    UINib *nib = [UINib nibWithNibName:@"ProjectTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"project"];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.webView.delegate = self;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"snap"] isDirectory:NO]]];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.comments removeAllObjects];
    // [START child_event_listener]
    // Listen for new comments in the Firebase database
    [_commentsRef
     observeEventType:FIRDataEventTypeChildAdded
     withBlock:^(FIRDataSnapshot *snapshot) {
         [self.comments addObject:snapshot];
         [self.tableView insertRowsAtIndexPaths:@[
                                                  [NSIndexPath indexPathForRow:self.comments.count - 1 inSection:kSectionComments]
                                                  ]
                               withRowAnimation:UITableViewRowAnimationAutomatic];
     }];
    // Listen for deleted comments in the Firebase database
    [_commentsRef
     observeEventType:FIRDataEventTypeChildRemoved
     withBlock:^(FIRDataSnapshot *snapshot) {
         int index = [self indexOfMessage:snapshot];
         [self.comments removeObjectAtIndex:index];
         [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:kSectionComments]]
                               withRowAnimation:UITableViewRowAnimationAutomatic];
     }];
    // [END child_event_listener]
    
    // [START project_value_event_listener]
    _refHandle = [_projectRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *projectDict = snapshot.value;
        // [START_EXCLUDE]
        [_project setValuesForKeysWithDictionary:projectDict];
        [self.tableView reloadData];
        self.navigationItem.title = _project.title;
        // [END_EXCLUDE]
    }];
    // [END project_value_event_listener]
}

- (int) indexOfMessage:(FIRDataSnapshot *)snapshot {
    int index = 0;
    for (FIRDataSnapshot *comment in _comments) {
        if ([snapshot.key isEqualToString:comment.key]) {
            return index;
        }
        ++index;
    }
    NSLog(@"index = %d",index);
    return -1;
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.commentsRef keepSynced:NO];
    [self.projectRef removeObserverWithHandle:_refHandle];
    [self.commentsRef removeAllObservers];
}

- (IBAction)sendComment:(UIButton *)sender {
    [self textFieldShouldReturn:_commentField];
    _commentField.enabled = NO;
    sender.enabled = NO;
    NSString *uid = [FIRAuth auth].currentUser.uid;
    [[[[FIRDatabase database].reference child:@"users"] child:uid]
     observeSingleEventOfType:FIRDataEventTypeValue
     withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
         NSDictionary *user = snapshot.value;
         NSString *username = user[@"username"];
         NSDictionary *comment = @{@"uid": uid,
                                   @"author": username,
                                   @"text": _commentField.text};
         [[_commentsRef childByAutoId] setValue:comment];
         _commentField.text = @"";
         _commentField.enabled = YES;
         sender.enabled = YES;
     }];
}



- (NSString *) getUid {
    return [FIRAuth auth].currentUser.uid;
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kSectionSend ) {
        return 1;
    } else if (section == kSectionComments) {
        return _comments.count;
    }
    NSAssert(NO, @"Unexpected section");
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    NSString *uid = [FIRAuth auth].currentUser.uid;
    
    if (indexPath.section == kSectionComments) {
        static NSString *CellIdentifier = @"comment";
        ProjectDetailTableViewCell * pCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        NSDictionary *comment = _comments[indexPath.row].value;
        //author
        pCell.titleLabel.text = comment[@"author"];
        //comment
        NSString *detailText = comment[@"text"];
        
        //if its my own commentUID
        NSString *commentUID = comment[@"uid"];
        bool isMyComment = [uid isEqualToString:commentUID];
        if(isMyComment){
            pCell.titleLabel.text = @"";
            pCell.detailLabel.textAlignment = NSTextAlignmentRight;
        }else{
            pCell.titleLabel.text = comment[@"author"];
            pCell.detailLabel.textAlignment = NSTextAlignmentLeft;
        }
        
        pCell.indexPath = indexPath;
        pCell.webView = self.webView;
        //pCell.detailLabel.text = detailText;

        if (![self isCommand:detailText]){
            //not a command
            pCell.isCommand = NO;
            pCell.detailLabel.text = detailText;
            pCell.detailStr = detailText;
        }else{
            //is a command
            pCell.isCommand = YES;
            //cut prefix
            NSString *noPrefixText = [detailText substringFromIndex:([COMMANDPREFIX length]+1)];
            pCell.detailLabel.text = noPrefixText;
            //NSLog(@"noPrefixText = %@",noPrefixText);
            //NSLog(@"decodedText = %@",decodedText);
            NSData *jsonData = [noPrefixText dataUsingEncoding:NSUTF8StringEncoding];
            NSError *e = nil;
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
            if (!jsonArray) {
                NSLog(@"Error parsing JSON: %@", e);
                pCell.detailLabel.text = noPrefixText;
                pCell.detailStr = noPrefixText;
            } else {
                //part 1 of array is a output text
                //part 2 of array is detailed text of a script can be transfferred back to snap!
                pCell.detailLabel.text = noPrefixText;
                NSLog(@"json transferred completed.");
                NSLog(@"part 1 = %@",jsonArray[0]);
                NSLog(@"part 2 = %@",[NSString stringWithFormat:@"%@",jsonArray[1]]);
                pCell.detailLabel.text = jsonArray[0];
                pCell.detailLabel.textColor = [UIColor redColor];
                pCell.detailStr = [NSString stringWithFormat:@"%@",jsonArray[1]];
                
            }
        }
        return pCell;
    } else if (indexPath.section == kSectionSend) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"send"];
        _commentField = [(UITextField *) cell viewWithTag:7];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

// UITextViewDelegate protocol method
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

// UIWebViewDelegate protocol method
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"text\").innerHTML=\"Hello World\";"];
    NSString *windowWidth = [webView stringByEvaluatingJavaScriptFromString:@"window.innerWidth;"];
    NSString *windowHeight = [webView stringByEvaluatingJavaScriptFromString:@"window.innerHeight;"];
    NSLog(@"Window Inner Width = %@ , Window Inner Height= %@", windowWidth, windowHeight);
    NSString *windowLocation = [webView stringByEvaluatingJavaScriptFromString:@"window.navigator.language;"];
    NSLog(@"window.navigator.userLanguage = %@",windowLocation);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //skyapp1
    if ([[[request URL] absoluteString] hasPrefix:@"skyappios:webToNativeCall"]) {
        // Call the given selector
        [self performSelector:@selector(webToNativeCall)];
        // Cancel the location change
        return NO;
    }else{
        //skyapp2
        if ([[[request URL] absoluteString] hasPrefix:@"skyappios:sendToPeers"]) {
            // Call the given selector
            NSString * str = [[request URL] absoluteString];
            str = [str stringByRemovingPercentEncoding]; //for javascript to ios
            str = [str stringByReplacingOccurrencesOfString:@"/\"" withString:@"\\\""]; //for json decoding/encoding
            [self performSelector:@selector(sendToPeers:) withObject:str];//str
            // Cancel the location change
            return NO;
        }
    }
    return YES;
}

//skyapp1
- (void)webToNativeCall{
    NSString *returnvalue =  [self.webView stringByEvaluatingJavaScriptFromString:@"addOne(4);"];
    NSLog(@"returnvalue = %@",returnvalue);
}

//skyapp2
- (void)sendToPeers:(NSString *)str {
    NSLog(@"command = %@",str);
    [self sendCommand:str];
}

- (void)sendCommand:(NSString *)cmd{
    NSString *uid = [FIRAuth auth].currentUser.uid;
    [[[[FIRDatabase database].reference child:@"users"] child:uid]
     observeSingleEventOfType:FIRDataEventTypeValue
     withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
         NSDictionary *user = snapshot.value;
         NSString *username = user[@"username"];
         NSDictionary *comment = @{@"uid": uid,
                                   @"author": username,
                                   @"text": cmd};
         [[_commentsRef childByAutoId] setValue:comment];
     }];
}

- (BOOL)isCommand:(NSString *)str{
    if ([str hasPrefix:COMMANDPREFIX]){
        return YES;
    }else{
        return NO;
    }
}


@end
