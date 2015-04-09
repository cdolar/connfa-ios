//
//  The MIT License (MIT)
//  Copyright (c) 2014 Lemberg Solutions Limited
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//   The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "DCSideMenuViewController.h"
#import "DCSideMenuCell.h"
#import "DCBaseViewController.h"
#import "DCAppFacade.h"
#import "DCSideMenuType.h"
#import "DCMenuStoryboardHelper.h"
#import "DCProgramViewController.h"
#import "UIConstants.h"
#import "DCFavoritesViewController.h"
#import "DCLimitedNavigationController.h"
#import "DCDayEventsController.h"

@class DCEvent;

#define kMenuItemTitle              @"MenuItemTitle"
#define kMenuItemIcon               @"MenuItemIcon"
#define kMenuItemSelectedIcon       @"MenuItemSelectedIcon"
#define kMenuItemControllerId       @"MenuItemControllerId"


@interface DCSideMenuViewController ()

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* topBackgroundViewHeight;

@property (nonatomic, strong) NSArray *arrayOfCaptions;
@property (nonatomic, strong) NSIndexPath* activeCellPath;
@property (nonatomic, strong) DCEvent *event;

@end


@implementation DCSideMenuViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.arrayOfCaptions = @[
                                @{ kMenuItemTitle: @"Schedule",
                                   kMenuItemIcon: @"menu_icon_program",
                                   kMenuItemSelectedIcon: @"menu_icon_program_sel",
                                   kMenuItemControllerId: @"DCProgramViewController"
                                   },
                                @{
                                    kMenuItemTitle: @"BoFs",
                                    kMenuItemIcon: @"menu_icon_bofs",
                                    kMenuItemSelectedIcon: @"menu_icon_bofs_sel",
                                    kMenuItemControllerId: @"DCProgramViewController"
                                    },
                                @{
                                    kMenuItemTitle: @"Social Events",
                                    kMenuItemIcon: @"menu_icon_social",
                                    kMenuItemSelectedIcon: @"menu_icon_social_sel",
                                    kMenuItemControllerId: @"DCProgramViewController"
                                    },
                                @{
                                    kMenuItemTitle: @"Speakers",
                                    kMenuItemIcon: @"menu_icon_speakers",
                                    kMenuItemSelectedIcon: @"menu_icon_speakers_sel",
                                    kMenuItemControllerId: @"SpeakersViewController"
                                    },
                                @{
                                    kMenuItemTitle: @"My Schedule",
                                    kMenuItemIcon: @"menu_icon_my_schedule",
                                    kMenuItemSelectedIcon: @"menu_icon_my_schedule_sel",
                                    kMenuItemControllerId: @"DCProgramViewController"
                                    },
                                @{
                                    kMenuItemTitle: @"Location",
                                    kMenuItemIcon: @"menu_icon_location",
                                    kMenuItemSelectedIcon: @"menu_icon_location_sel",
                                    kMenuItemControllerId: @"LocationViewController"
                                    },
//                                @{
//                                    kMenuItemTitle: @"Points of Interest",
//                                    kMenuItemIcon: @"menu_icon_points",
//                                    kMenuItemSelectedIcon: @"menu_icon_points_sel",
//                                    kMenuItemControllerId: @""
//                                    },
                                @{
                                    kMenuItemTitle: @"Info",
                                    kMenuItemIcon: @"menu_icon_about",
                                    kMenuItemSelectedIcon: @"menu_icon_about_sel",
                                    kMenuItemControllerId: @"InfoViewController"
                                    }
                             ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuStateDidChange:)
                                                 name:MFSideMenuStateNotificationEvent
                                               object:nil];
    
    //our first menu item is Program, this is actually the screen that we should see right after the login page, thats why lets just add it on top as if the user alerady selected it
    
    self.activeCellPath = [NSIndexPath indexPathForRow:DCMENU_PROGRAM_ITEM inSection:0];
    [self tableView:self.tableView didSelectRowAtIndexPath:self.activeCellPath];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.event) {
        
        [self showViewControllerAssociatedWithMenuItem:DCMENU_MYSCHEDULE_ITEM];
        
        UINavigationController *navCon = self.sideMenuContainer.centerViewController;
        if ([navCon isKindOfClass:[UINavigationController class]]) {
            
            DCProgramViewController *programController = (DCProgramViewController *)navCon.topViewController;
            if ([programController respondsToSelector:@selector(openDetailScreenForEvent:)]) {
                
                [programController openDetailScreenForEvent:self.event];
                self.event = nil;
            }
        }
    }
}


#pragma mark - Private

- (void) menuStateDidChange:(NSNotification*)notification
{
    NSDictionary *dict = [notification userInfo];
    MFSideMenuStateEvent eventType = (MFSideMenuStateEvent)[dict[@"eventType"] integerValue];
    
    if (eventType == MFSideMenuStateEventMenuDidClose)
        [self.sideMenuContainer.leftMenuViewController setNeedsStatusBarAppearanceUpdate];
    else if (eventType == MFSideMenuStateEventMenuDidOpen)
        [self setNeedsStatusBarAppearanceUpdate];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (void) showViewControllerAssociatedWithMenuItem:(DCMenuSection)menuItem
{
    NSString *storyboardControllerID = self.arrayOfCaptions[menuItem][kMenuItemControllerId];
    NSAssert(storyboardControllerID.length, @"No Storyboard ID for Menu item view controller");
    
    DCBaseViewController* rootMenuVC = [self getViewController:menuItem];
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController: rootMenuVC];
    
        // disable swipe-to-Back gesture
    if ([navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [self arrangeNavigationBarForController: rootMenuVC menuItem:menuItem];

    
    self.sideMenuContainer.centerViewController = navigationController;
    [self.sideMenuContainer setMenuState:MFSideMenuStateClosed completion:nil];
}

- (void) arrangeNavigationBarForController:(DCBaseViewController*)aController menuItem:(DCMenuSection)menuItem
{
    // add proper Title
    NSString *title = self.arrayOfCaptions[menuItem][kMenuItemTitle];
    aController.navigationItem.title = title;
    
    // add left Menu button to all Controllers
    UIImage *image = (menuItem == DCMENU_INFO_ITEM) ? [UIImage imageNamed:@"menu-icon-dark"] : [UIImage imageNamed:@"menu-icon"];
    UIButton *button = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, image.size.width, image.size.height)];
    [button setBackgroundImage: image forState: UIControlStateNormal];
    [button addTarget: self action:@selector(leftSideMenuButtonPressed:) forControlEvents: UIControlEventTouchUpInside];
    aController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: button];
}

- (void)openEventFromFavorite:(DCEvent *)event
{
    self.event = event;
}

#pragma mark - User actions

- (void)leftSideMenuButtonPressed:(id)sender
{
    [self.sideMenuContainer toggleLeftSideMenuCompletion:nil];
}

- (DCBaseViewController*) getViewController:(DCMenuSection)menuItem
{
    NSString *storyboardName = [self storyboardNameForMenuItem:menuItem];
    NSString *controllerId = self.arrayOfCaptions[menuItem][kMenuItemControllerId];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    
    DCBaseViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:controllerId];

    if ([viewController isKindOfClass:[DCProgramViewController class]])
    {
        [(DCProgramViewController*)viewController setEventsStrategy:[DCMenuStoryboardHelper strategyForEventMenuType:menuItem]];
    }

    return viewController;
}
- (NSString *)storyboardNameForMenuItem:(DCMenuSection)menuSection
{
    //  TODO: This functionlity return storyboard for appropriate menu items
    NSString *defaultStoryboardName = @"Main";
    
    switch (menuSection) {
        case DCMENU_MYSCHEDULE_ITEM:
        case DCMENU_SOCIAL_EVENTS_ITEM:
        case DCMENU_BOFS_ITEM:
        case DCMENU_PROGRAM_ITEM:
            defaultStoryboardName = @"Events";
            break;
            
        case DCMENU_SPEAKERS_ITEM:
            defaultStoryboardName = @"Speakers";
            break;
            
        case DCMENU_INFO_ITEM:
            defaultStoryboardName = @"Info";
            break;
            
        default:
            break;
    }
    return defaultStoryboardName;
}


#pragma mark - UITableView delegate

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [tableView dequeueReusableCellWithIdentifier: @"SideMenuHeaderId"];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [UIImage imageNamed:@"nav_header"].size.height + 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"SideMenuCellIdentifier";
    
    DCSideMenuCell *cell = (DCSideMenuCell*)[tableView dequeueReusableCellWithIdentifier: cellIdentifier];
    
    NSDictionary *itemDict   = [self.arrayOfCaptions objectAtIndex: indexPath.row];
    cell.captionLabel.text   = itemDict[kMenuItemTitle];
    
    BOOL isActiveCell = indexPath.row == self.activeCellPath.row;
    cell.leftImageView.image = [UIImage imageNamed:itemDict[isActiveCell ? kMenuItemSelectedIcon : kMenuItemIcon]];
    cell.captionLabel.textColor = isActiveCell ? NAV_BAR_COLOR : MENU_DESELECTED_ITEM_TITLE_COLOR;
    
    cell.separatorView.hidden = !(indexPath.row % 3 == 2);

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        // Change cells view to display Selection 
    DCSideMenuCell* lastSelected = (DCSideMenuCell*)[tableView cellForRowAtIndexPath:self.activeCellPath];
    DCSideMenuCell* newSelected = (DCSideMenuCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    lastSelected.leftImageView.image = [UIImage imageNamed:[self.arrayOfCaptions objectAtIndex: self.activeCellPath.row][kMenuItemIcon]];
    lastSelected.captionLabel.textColor = MENU_DESELECTED_ITEM_TITLE_COLOR;
    
    newSelected.leftImageView.image = [UIImage imageNamed:[self.arrayOfCaptions objectAtIndex: indexPath.row][kMenuItemSelectedIcon]];
    newSelected.captionLabel.textColor = NAV_BAR_COLOR;
    
    self.activeCellPath = indexPath;
    
    [self showViewControllerAssociatedWithMenuItem:(DCMenuSection)indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfCaptions.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark - UIScrollView delegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView)
    {
            // we change top background height to provide Background color different below the tableView in the top and bottom of tableView. Top should stratch with table scrolling
        float offset = scrollView.contentOffset.y;
        
        if (offset < 0)
            self.topBackgroundViewHeight.constant = - offset;
    }
    
}


@end
