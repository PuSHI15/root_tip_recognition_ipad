//
//  ViewController.m
//  finalProject_iOS
//
//  Created by 石璞 on 10/03/2014.
//  Copyright (c) 2014 Pu SHI. All rights reserved.
//

#import "ViewController.h"

using namespace std;
using namespace cv;

@interface ViewController ()
{
    MySVM svm;
}

@end


@implementation ViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.scrollView.minimumZoomScale=1.0;
    self.scrollView.maximumZoomScale=6.0;
    self.scrollView.contentSize=CGSizeMake(1280, 960);
    self.scrollView.delegate = self;
    self.displayImage.userInteractionEnabled = NO;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)invokeCamera:(id)sender {
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Camera not available"
                                                            message:@"The Camera is not Available on Your Device"
                                                           delegate:nil cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
        
        [alertView show];
    } else {
        UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
        ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
        ipc.allowsEditing = NO;
        
        ipc.delegate = self;
        [self presentViewController:ipc animated:YES completion:nil];
    }
}

- (IBAction)invokeLib:(id)sender {
    
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    ipc.allowsEditing = NO;
    
    ipc.delegate = self;
    [self presentViewController:ipc  animated:YES completion:nil];
    
}

- (IBAction)showSelectionMenu:(UILongPressGestureRecognizer *)sender {
    if ([sender state] == UIGestureRecognizerStateBegan) {
        
        [self becomeFirstResponder];
        //self.pieceForReset = [gestureRecognizer view];
        
        NSString *menuItemTitle1 = NSLocalizedString(@"Root tip", @"select root-tips menu title");
        NSString *menuItemTitle2 = NSLocalizedString(@"Non-root tip", @"select non-root tips menu title");
        NSString *menuItemTitle3 = NSLocalizedString(@"Delete", @"Delete selected area menu title");
        NSString *menuItemTitle4 = NSLocalizedString(@"Change to Root tip", @"Converse non-root tip to root tip");
        NSString *menuItemTitle5 = NSLocalizedString(@"Change to Non-root tip", @"Converse root tip to non-root tip");
        
        CGPoint location = [sender locationInView:[sender view]];
        CGRect menuLocation = CGRectMake(location.x, location.y, 0, 0);
        _displayImage.model.temp = location;
        
        UIMenuItem *rtMenuItem = [[UIMenuItem alloc] initWithTitle:menuItemTitle1
                                                            action:@selector(selectRoot:)];
        UIMenuItem *nrtMenuItem = [[UIMenuItem alloc] initWithTitle:menuItemTitle2
                                                             action:@selector(selectNRoot:)];
        UIMenuItem *deleMenuItem = [[UIMenuItem alloc] initWithTitle:menuItemTitle3
                                                              action:@selector(deleteRect:)];
        UIMenuItem *rt2nrtMenuItem = [[UIMenuItem alloc] initWithTitle:menuItemTitle5
                                                                action:@selector(rt2nrt: )];
        UIMenuItem *nrt2rtMenuItem = [[UIMenuItem alloc] initWithTitle:menuItemTitle4
                                                                action:@selector(nrt2rt: )];
        
        
        
        
        if ([self isPointInExistingRTFrame:location]) {
            UIMenuController *deleMenu = [UIMenuController sharedMenuController];
            [deleMenu setMenuItems:[NSArray arrayWithObjects:rt2nrtMenuItem,deleMenuItem, nil]];
            [deleMenu setTargetRect:menuLocation inView:[sender view]];
            [deleMenu setMenuVisible:YES animated:YES];
            NSLog(@"delete menue appear");
        }else if ( [self isPointInExistingNRTFrame:location]) {
            UIMenuController *deleMenu = [UIMenuController sharedMenuController];
            [deleMenu setMenuItems:[NSArray arrayWithObjects:nrt2rtMenuItem,deleMenuItem, nil]];
            [deleMenu setTargetRect:menuLocation inView:[sender view]];
            [deleMenu setMenuVisible:YES animated:YES];
        }
        else if(!(location.x < 8 || location.x > self.view.bounds.size.width - 8 || location.y < 8 || location.y > self.view.bounds.size.height - 8)){
            UIMenuController *menuController = [UIMenuController sharedMenuController];
            [menuController setMenuItems:[NSArray arrayWithObjects:rtMenuItem, nrtMenuItem, nil]];
            [menuController setTargetRect:menuLocation inView:[sender view]];
            [menuController setMenuVisible:YES animated:YES];
            NSLog(@"Long Press Gesture Handling");
        }else{
            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                               message:@"Frame will be out of view"
                                                              delegate:self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
            [theAlert show];
        }
    }
    
}


- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)selectRoot:(UIMenuItem *)controller
{
    RootTips *rtp = [[RootTips alloc] init];
    rtp.centerPoint = _displayImage.model.temp;
    rtp.height = 16;
    rtp.width = 16;
    rtp.imageOfRTips = [self cutImageFromOrignalImageRT:rtp];
    [_displayImage.model.selectedRTips addObject:rtp];
    for (int i = 1; i<=3; ) {
        //NSLog(@"ENTER MAKERAMDOM");
        CGPoint p = [self makeRandomPoint];
        if ([self isPointCanMakeFrame:p]) {
            Non_RootTips *nrtp = [[Non_RootTips alloc] init];
            nrtp.centerPoint = p;
            nrtp.height = 16;
            nrtp.width = 16;
            nrtp.imageOfNRTip = [self cutImageFromOrignalImageNRT:nrtp];
            [_displayImage.model.selectedNRTips addObject:nrtp];
            i++;
        }
    }
    [_displayImage setNeedsDisplay];
    
}

- (void)selectNRoot:(UIMenuItem *)controller
{
    if(![self isPointCanMakeFrame:_displayImage.model.temp]){
        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                           message:@"There will be a overlapping! \n Plese Choose Another"
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [theAlert show];
    }
    else{
        Non_RootTips *nrtp = [[Non_RootTips alloc] init];
        nrtp.centerPoint = _displayImage.model.temp;
        nrtp.height = 16;
        nrtp.width = 16;
        nrtp.imageOfNRTip = [self cutImageFromOrignalImageNRT:nrtp];
        [_displayImage.model.selectedNRTips addObject:nrtp];
        [_displayImage setNeedsDisplay];
    }
}

-(UIImage *)cutImageFromOrignalImageRT: (RootTips *)rtp
{
    CGRect rect = CGRectMake(rtp.centerPoint.x - (rtp.width/2),rtp.centerPoint.y-(rtp.height/2), rtp.width, rtp.height);
    CGImageRef imgRef = CGImageCreateWithImageInRect([_displayImage.model.image CGImage], rect);
    UIImage *img = [UIImage imageWithCGImage:imgRef];
    return img;
}

-(UIImage *)cutImageFromOrignalImageNRT: (Non_RootTips *)nrtp
{
    CGRect rect = CGRectMake(nrtp.centerPoint.x - (nrtp.width/2),nrtp.centerPoint.y-(nrtp.height/2), nrtp.width, nrtp.height);
    CGImageRef imgRef = CGImageCreateWithImageInRect([_displayImage.model.image CGImage], rect);
    UIImage *img = [UIImage imageWithCGImage:imgRef];
    return img;
}

- (void)rt2nrt:(UIMenuItem *)controller
{
    Non_RootTips *nrtp = [[Non_RootTips alloc] init];
    nrtp.centerPoint = [[_displayImage.model.selectedRTips objectAtIndex:_displayImage.model.rtIndex] centerPoint];
    nrtp.height = [[_displayImage.model.selectedRTips objectAtIndex:_displayImage.model.rtIndex] height];
    nrtp.width = [[_displayImage.model.selectedRTips objectAtIndex:_displayImage.model.rtIndex] width];
    nrtp.imageOfNRTip = [[_displayImage.model.selectedRTips objectAtIndex:_displayImage.model.rtIndex] imageOfRTips];
    [_displayImage.model.selectedRTips removeObjectAtIndex:_displayImage.model.rtIndex];
    [_displayImage.model.selectedNRTips addObject:nrtp];
    [_displayImage setNeedsDisplay];
}

- (void)nrt2rt:(UIMenuItem *)controller
{
    RootTips *rtp = [[RootTips alloc] init];
    rtp.centerPoint = [[_displayImage.model.selectedNRTips objectAtIndex:_displayImage.model.nrtIndex] centerPoint];
    rtp.height = [[_displayImage.model.selectedNRTips objectAtIndex:_displayImage.model.nrtIndex] height];
    rtp.width = [[_displayImage.model.selectedNRTips objectAtIndex:_displayImage.model.nrtIndex] width];
    rtp.imageOfRTips = [[_displayImage.model.selectedNRTips objectAtIndex:_displayImage.model.nrtIndex] imageOfNRTip];
    [_displayImage.model.selectedNRTips removeObjectAtIndex:_displayImage.model.nrtIndex];
    [_displayImage.model.selectedRTips addObject:rtp];
    [_displayImage setNeedsDisplay];
}


- (void)deleteRect:(UIMenuItem *)controller
{
    if(!(_displayImage.model.rtIndex == -1)){
        NSLog(@"good");
        [_displayImage.model.selectedRTips removeObjectAtIndex:_displayImage.model.rtIndex];
        NSLog(@"good");
    }
    if (!(_displayImage.model.nrtIndex == -1)) {
        NSLog(@"good");
        [_displayImage.model.selectedNRTips removeObjectAtIndex:_displayImage.model.nrtIndex];
        NSLog(@"good");
    }
    //printf("number: %u\n", [_displayImage.selectedRTips count]);
    [_displayImage setNeedsDisplay];
    
    _displayImage.model.rtIndex = -1;
    _displayImage.model.nrtIndex = -1;
}

- (BOOL)isPointInExistingRTFrame: (CGPoint)point
{
    BOOL result = NO;
    
    _displayImage.model.rtIndex = -1;
    
    for (RootTips *rt in _displayImage.model.selectedRTips) {
        if ((point.x > rt.centerPoint.x-(rt.width/2)) && (point.x < rt.centerPoint.x +(rt.width/2))) {
            if ((point.y < rt.centerPoint.y + (rt.height/2)) && (point.y > rt.centerPoint.y -(rt.height/2))) {
                result = YES;
                _displayImage.model.rtIndex = [_displayImage.model.selectedRTips indexOfObject:rt];
                break;
            }
            
        }
        
    }
    return result;
}

- (BOOL)isPointInExistingNRTFrame: (CGPoint)point
{
    BOOL result = NO;

    _displayImage.model.nrtIndex = -1;
    
    for (Non_RootTips *nrt in _displayImage.model.selectedNRTips) {
        if ((point.x > nrt.centerPoint.x-(nrt.width/2)) && (point.x < nrt.centerPoint.x +(nrt.width/2))) {
            if ((point.y < nrt.centerPoint.y + (nrt.height/2)) && (point.y > nrt.centerPoint.y -(nrt.height/2))) {
                result =  YES;
                _displayImage.model.nrtIndex = [_displayImage.model.selectedNRTips indexOfObject:nrt];
                break;
            }
            
        }
        
    }
    return result;
}

- (BOOL)isPointCanMakeFrame: (CGPoint)point
{
    BOOL result1 = YES;
    BOOL result2 = YES;
    
    for (RootTips *rt in _displayImage.model.selectedRTips) {
        if ((point.x > rt.centerPoint.x-(rt.width + 8)) && (point.x < rt.centerPoint.x + (rt.width+8))) {
            if ((point.y < rt.centerPoint.y + (rt.height + 8)) && (point.y > rt.centerPoint.y -(rt.height+8))) {
                result1 = NO;
                break;
            }
            
        }
        
    }
    
    for (Non_RootTips *nrt in _displayImage.model.selectedNRTips) {
        if ((point.x > nrt.centerPoint.x-(nrt.width + 8)) && (point.x < nrt.centerPoint.x + (nrt.width +8))) {
            if ((point.y < nrt.centerPoint.y + (nrt.height + 8)) && (point.y > nrt.centerPoint.y - (nrt.height + 8))) {
                result2 = NO;
                break;
            }
            
        }
        
    }
    return (result1 && result2);
}

- (CGPoint) makeRandomPoint
{
    CGPoint result;
    srandom((unsigned)time(NULL));
    CGRect r = [_displayImage bounds];
    result.x = (r.origin.x + 8) + random() % (int)(r.size.width -8 - (r.origin.x + 8));
    result.y = (r.origin.y + 8) + random() % (int)(r.size.height-8 - (r.origin.y +8));
    return result;
    
}

- (IBAction)learnFeature:(id)sender
{
   
    
    Mat sampleFeatureMat;
    Mat sampleLabelMat;
    Mat halfSampleTrain;
    Mat halfSampleTrain_Label;
    Mat halfSampleTest;
    Mat halfSampleTest_Label;
    Mat predictLabel;
    HOGDescriptor hog(cv::Size(16,16),cv::Size(16,16),cv::Size(8,8),cv::Size(8,8), 9);
    
    NSString *posFolder = [[NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"/posSample"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:posFolder])
        [[NSFileManager defaultManager] createDirectoryAtPath:posFolder
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:nil];
    
    
    NSString *negFolder = [[NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"/negSample"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:negFolder])
        [[NSFileManager defaultManager] createDirectoryAtPath:negFolder
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:nil];
    
    
    NSString *posPath = [[NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"posPath.txt"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:posPath])
        [[NSFileManager defaultManager] createFileAtPath:posPath
                                                contents:nil
                                              attributes:nil];
    
    
    NSString *negPath = [[NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"negPath.txt"];
    if (![[NSFileManager defaultManager] fileExistsAtPath: negPath])
        [[NSFileManager defaultManager] createFileAtPath: negPath
                                                contents:nil
                                              attributes:nil];
    
    for ( ; _displayImage.model.indexForPos < [_displayImage.model.selectedRTips count]; _displayImage.model.indexForPos++)
    {
        //NSLog(@"Saving");
        for ( ; ; ) {
            NSString *picPath = [[NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent: [[@"/posSample/" stringByAppendingString:[NSString stringWithFormat: @"%d", _displayImage.model.pospicName]] stringByAppendingString:@".png"]];
            if (![[NSFileManager defaultManager] fileExistsAtPath:picPath])
            {
                NSData *pngData = UIImagePNGRepresentation([[_displayImage.model.selectedRTips objectAtIndex:_displayImage.model.indexForPos] imageOfRTips]);
                [pngData writeToFile:picPath atomically:YES];
                NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:posPath];
                [fileHandler seekToEndOfFile];
                [fileHandler writeData:[[picPath stringByAppendingString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                [fileHandler closeFile];
                _displayImage.model.pospicName++;
                break;
            }
            else
            {
                _displayImage.model.pospicName++;
            }
        }
    }
    
    for ( ; _displayImage.model.indexForNeg < [_displayImage.model.selectedNRTips count]; _displayImage.model.indexForNeg++)
    {
        //NSLog(@"Saving");
        for ( ; ; ) {
            NSString *picPath = [[NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent: [[@"/negSample/" stringByAppendingString:[NSString stringWithFormat: @"%d", _displayImage.model.negpicName]] stringByAppendingString:@".png"]];
            if (![[NSFileManager defaultManager] fileExistsAtPath:picPath])
            {
                NSData *pngData = UIImagePNGRepresentation([[_displayImage.model.selectedNRTips objectAtIndex:_displayImage.model.indexForNeg] imageOfNRTip]);
                [pngData writeToFile:picPath atomically:YES];
                NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:negPath];
                [fileHandler seekToEndOfFile];
                [fileHandler writeData:[[picPath stringByAppendingString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                [fileHandler closeFile];
                _displayImage.model.negpicName++;
                break;
            }
            else
            {
                _displayImage.model.negpicName++;
            }
        }
    }
    
    NSCharacterSet *newlineCharSet = [NSCharacterSet newlineCharacterSet];
    NSString* posContents = [NSString stringWithContentsOfFile:posPath
                                                      encoding:NSUTF8StringEncoding
                                                         error:nil];
    NSString* negContents = [NSString stringWithContentsOfFile:negPath
                                                      encoding:NSUTF8StringEncoding
                                                         error:nil];
    NSArray *posLines = [posContents componentsSeparatedByCharactersInSet:newlineCharSet];
    NSArray *negLines = [negContents componentsSeparatedByCharactersInSet:newlineCharSet];
    NSUInteger samplesCount = [posLines count] + [negLines count] -2;
    NSUInteger halfSamplesCount = samplesCount/2;
    
    if ([posLines count] == 0 && [negLines count] ==0) {
        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                           message:@"There is no sample to be trained"
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [theAlert show];
    }else{
    for (NSUInteger i = 0; i < [posLines count]-1; i++)
    {
        //NSLog(@"Start learning");
        UIImage *picToProcess = [UIImage imageWithContentsOfFile:[posLines objectAtIndex:i]];
        Mat src = [self cvMatFromUIImage:picToProcess];
        vector<float> descriptors;
        hog.compute(src,descriptors,cv::Size(8,8));
        if (i ==0 ) {
            _displayImage.model.DescriptorDim = (int)descriptors.size();
            sampleFeatureMat = Mat::zeros((int)samplesCount, _displayImage.model.DescriptorDim, CV_32FC1);
            sampleLabelMat = Mat::zeros((int)samplesCount, 1, CV_32FC1);
            halfSampleTrain = Mat::zeros((int)halfSamplesCount, _displayImage.model.DescriptorDim, CV_32FC1);
            halfSampleTrain_Label = Mat::zeros((int)halfSamplesCount, 1, CV_32FC1);
            halfSampleTest = Mat::zeros((int)(samplesCount - halfSamplesCount), _displayImage.model.DescriptorDim, CV_32FC1);
            halfSampleTest_Label = Mat::zeros((int)(samplesCount - halfSamplesCount), 1, CV_32FC1);
            predictLabel = Mat::zeros((int)(samplesCount - halfSamplesCount), 1, CV_32FC1);
            
        }
        for(int j=0; j<_displayImage.model.DescriptorDim; j++)
        {
            sampleFeatureMat.at<float>((int)i,j) = descriptors[j];
            if (i < ([posLines count]-1)/2) {
                halfSampleTrain.at<float>((int)i, j) = descriptors[j];
            }else{
                halfSampleTest.at<float>((int)(i - ([posLines count]-1)/2), j) = descriptors[j];
            }
        }

        sampleLabelMat.at<float>((int)i,0) = 1;
        if (i < ([posLines count]-1)/2) {
            halfSampleTrain_Label.at<float>((int)i, 0) = 1;
        }else{
            halfSampleTest_Label.at<float>((int)(i - ([posLines count]-1)/2), 0) = 1;
        }
        
    }
    
    for (NSUInteger i = 0; i < [negLines count] -1; i++)
    {
        //NSLog(@"start processing nonrt");
        UIImage *picToProcess = [UIImage imageWithContentsOfFile:[negLines objectAtIndex:i]];
        Mat src = [self cvMatFromUIImage:picToProcess];
        vector<float> descriptors;
        hog.compute(src,descriptors,cv::Size(8,8));
        for(int j=0; j< _displayImage.model.DescriptorDim; j++)
        {
            sampleFeatureMat.at<float>((int)i + (int)[posLines count]-1,j) = descriptors[j];
            if (i < ([negLines count]-1)/2) {
                halfSampleTrain.at<float>((int)i + ((int)[posLines count]-1)/2, j) = descriptors[j];
            }else{
                halfSampleTest.at<float>((int)(i - ([negLines count]-1)/2) + (int)(([posLines count]-1) - ([posLines count]-1)/2), j) = descriptors[j];
            }
        }
        sampleLabelMat.at<float>((int)i + (int)[posLines count]-1 ,0) = -1;
        if (i < ([negLines count]-1)/2) {
            halfSampleTrain_Label.at<float>((int)i + ((int)[posLines count]-1)/2, 0) = -1;
        }else{
            halfSampleTest_Label.at<float>((int)(i - ([negLines count]-1)/2) + (int)(([posLines count]-1) - ([posLines count]-1)/2), 0) = -1;
        }

        
    }
        
    
    CvTermCriteria criteria = cvTermCriteria(CV_TERMCRIT_ITER+CV_TERMCRIT_EPS, 1000, FLT_EPSILON);
    
  
    // Find optimal paramter for slackvariable
    // To do this you should split all data in a train and test set
    double slackvariable = 0.01;
    double bestscore = 0;
    double currentscore = 0;
    int match;

    for (double sv = 0.01; sv < 1000; sv *= 1.1) {
 
        match = 0;
        CvSVMParams param(CvSVM::C_SVC, CvSVM::LINEAR, 0, 1, 0, sv, 0, 0, 0, criteria); // using current slackvariable
        
        
        svm.train(halfSampleTrain, halfSampleTrain_Label, Mat(), Mat(), param);
        svm.predict(halfSampleTest, predictLabel);
        
      
        for(int i = 0; i < predictLabel.rows; i++)
        {
            if (predictLabel.at<float>(i,0) == halfSampleTest_Label.at<float>(i,0)) {
                match++;
            }
        }
        
        cout<<sv<<", "<<match<<endl;
        
        //cout<<predictLabel.rows<<endl;
        currentscore = match/(double)(predictLabel.rows);
        
        //double currentscore = SOME_EVALUATION_TEST(svm, sampleFeatureMat_halfTest, sampleLabelMat_halfTest);
        //cout << "This is the score for slackvarable....\n";'
        if (currentscore > bestscore){
            bestscore = currentscore;
            slackvariable = sv;
        }
        //cout<<sv<<endl;
        //cout<<bestscore<<endl;
    }
    // Now train final svm using all data
    
    cout<<halfSampleTest_Label.rows<<endl;
    cout<<slackvariable<<endl;
    cout<<bestscore<<endl;
    cout<<sampleFeatureMat.rows<<endl;
    cout<<"Start Training"<<endl;
    CvSVMParams param(CvSVM::C_SVC, CvSVM::LINEAR, 0, 1, 0, 0.4, 0, 0, 0, criteria); /// using optimal slackvariable
    svm.train(sampleFeatureMat, sampleLabelMat, Mat(), Mat(), param);
    cout<<"Training Completed"<<endl;
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"svm.xml"];
    
    
    svm.save([fileName UTF8String]);
    
    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Congratulations"
                                                       message:@"You have succesfully trained \n Your own classifier!"
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
    [theAlert show];
    }
    
}

- (IBAction)predictRootTips:(id)sender
{
    if (_displayImage.model.image == Nil) {
        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                           message:@"No Picture to Detect!"
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [theAlert show];
    }else{
    NSString *fileName = [[NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"svm.xml"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileName])
    {
        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                           message:@"Please Train a Model First"
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [theAlert show];
    }else{
        svm.load([fileName UTF8String]);
        _displayImage.model.DescriptorDim = svm.get_var_count();
        int supportVectorNum = svm.get_support_vector_count();
        cout<<"Support Vector："<<supportVectorNum<<endl;
        
        Mat alphaMat = Mat::zeros(1, supportVectorNum, CV_32FC1);
        Mat supportVectorMat = Mat::zeros(supportVectorNum, _displayImage.model.DescriptorDim, CV_32FC1);
        Mat resultMat = Mat::zeros(1, _displayImage.model.DescriptorDim, CV_32FC1);
        
        for(int i=0; i<supportVectorNum; i++)
        {
            const float * pSVData = svm.get_support_vector(i);
            for(int j=0; j<_displayImage.model.DescriptorDim; j++)
            {
                
                supportVectorMat.at<float>(i,j) = pSVData[j];
            }
        }
        double * pAlphaData = svm.get_alpha_vector();
        for(int i=0; i<supportVectorNum; i++)
        {
            alphaMat.at<float>(0,i) = pAlphaData[i];
        }
        
        
        resultMat = -1 * alphaMat * supportVectorMat;
        
        
        vector<float> myDetector;
        
        for(int i=0; i<_displayImage.model.DescriptorDim; i++)
        {
            myDetector.push_back(resultMat.at<float>(0,i));
        }
        
        myDetector.push_back(svm.get_rho());
        cout<<"Dimension sof Detector："<<myDetector.size()<<endl;
       
        HOGDescriptor  myHOG(cv::Size(16,16), cv::Size(16,16), cv::Size(8,8), cv::Size(8,8), 9);
        myHOG.setSVMDetector(myDetector);
        
        NSString *hogdetectorPath = [[NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"hogdetector.txt"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:hogdetectorPath])
            [[NSFileManager defaultManager] createFileAtPath:hogdetectorPath contents:nil attributes:nil];
        NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:hogdetectorPath];
        [fileHandler seekToEndOfFile];
        for(int i=0; i<myDetector.size(); i++)
        {
            [fileHandler writeData:[[NSString stringWithFormat:@"%f", myDetector[i]] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        [fileHandler closeFile];
        
         Mat src = [self cvMatFromUIImage:_displayImage.model.image];
         vector<cv::Rect> found, found_filtered;
         cout<<"Start Detecting"<<endl;
         myHOG.detectMultiScale(src, found, 0, cv::Size(8,8), cv::Size(0,0), 1.05, 2);
         cout<<"Rect Found："<<found.size()<<endl;
         
        
         for(int i=0; i < found.size(); i++)
         {
         cv::Rect r = found[i];
         int j=0;
         for(; j < found.size(); j++)
             if(j != i && (r & found[j]) == r)
                 break;
         if( j == found.size())
             found_filtered.push_back(r);
         }
        
        
        
        [_displayImage.model.selectedRTips removeAllObjects];
        [_displayImage.model.selectedNRTips removeAllObjects];
        _displayImage.model.indexForNeg = 0;
        _displayImage.model.indexForPos = 0;
        
         
        
         for(int i=0; i<found_filtered.size(); i++)
         {
             
             cv::Rect r = found_filtered[i];
             RootTips *rt = [[RootTips alloc] init];
             rt.centerPoint = CGPointMake((CGFloat)(r.x+r.width/2), (CGFloat)(r.y+r.height/2));
             rt.height = 24;
             rt.width = 24;
             rt.imageOfRTips = [self cutImageFromOrignalImageRT:rt];
             [_displayImage.model.selectedRTips addObject:rt];
         }
        
        [_displayImage setNeedsDisplay];
        
      }
    }
    
}

- (IBAction)clearCanvas:(id)sender {
    [_displayImage.model.selectedNRTips removeAllObjects];
    [_displayImage.model.selectedRTips removeAllObjects];
    _displayImage.model.indexForPos = 0;
    _displayImage.model.indexForNeg = 0;
    _displayImage.model.rtIndex = -1;
    _displayImage.model.nrtIndex = -1;
    _displayImage.model.temp = CGPointMake(0, 0);
    _displayImage.model.DescriptorDim = 0;
    [_displayImage setNeedsDisplay];
}

- (IBAction)saveImage:(id)sender {
    UIGraphicsBeginImageContextWithOptions(_displayImage.bounds.size, _displayImage.opaque, 0.0);
    [_displayImage.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
    
}


#pragma mark ImagePicker Delegate

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    _displayImage.model.indexForPos = 0;
    _displayImage.model.indexForNeg = 0;
    _displayImage.model.rtIndex = -1;
    _displayImage.model.nrtIndex = -1;

    [_displayImage.model.selectedRTips removeAllObjects];
    [_displayImage.model.selectedNRTips removeAllObjects];
    
    [_displayImage.model setImage: [info objectForKey:UIImagePickerControllerOriginalImage]];
    UIGraphicsBeginImageContext(self.view.frame.size);
    [_displayImage.model.image drawInRect:self.view.bounds];
    [_displayImage.model setImage: UIGraphicsGetImageFromCurrentImageContext()];
    _displayImage.model = _displayImage.model;
    UIGraphicsEndImageContext();
    
    _displayImage.backgroundColor = [UIColor colorWithPatternImage:_displayImage.model.image];
    
    _displayImage.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(showSelectionMenu:)];
    lpgr.minimumPressDuration = 0.5; //seconds
    lpgr.delegate = self;
    [self.view addGestureRecognizer:lpgr];
    
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Image zoom

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.displayImage;
}

#pragma mark uiimagetomat

- (Mat)cvMatFromUIImage:(UIImage *)picture
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(picture.CGImage);
    CGFloat cols = picture.size.width;
    CGFloat rows = picture.size.height;
    
    Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), picture.CGImage);
    CGContextRelease(contextRef);
    
    Mat rgbMat(rows, cols, CV_8UC3); // 8 bits per component, 3 channels
    
    cvtColor(cvMat, rgbMat, CV_RGBA2RGB, 3);
    
    return rgbMat;
}


@end
