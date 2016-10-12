//
//  ViewController.h
//  finalProject_iOS
//
//  Created by 石璞 on 10/03/2014.
//  Copyright (c) 2014 Pu SHI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/objdetect/objdetect.hpp>
#include <opencv2/ml/ml.hpp>
#import "RootTips.h"
#import "viewToDisplay.h"
#import "Non_RootTips.h"
#import "modelClass.h"



class MySVM : public CvSVM
{
public:
    
    double * get_alpha_vector()
    {
        return this->decision_func->alpha;
    }
    
    float get_rho()
    {
        return this->decision_func->rho;
    }
};



@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, UINavigationControllerDelegate>
{
    
}

- (IBAction)invokeCamera:(id)sender;
- (IBAction)invokeLib:(id)sender;
- (IBAction)showSelectionMenu:(UILongPressGestureRecognizer *)sender;
- (IBAction)learnFeature:(id)sender;
- (IBAction)predictRootTips:(id)sender;
- (IBAction)saveImage:(id)sender;
- (IBAction)clearCanvas:(id)sender;


@property (weak, nonatomic) IBOutlet viewToDisplay *displayImage;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;



@end
