//
//  DCProgramItemsViewController.m
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/30/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCProgramItemsViewController.h"
#import "DCSpeechCell.h"
#import "DCSpeechOfDayCell.h"
#import "DCCofeeCell.h"
#import "DCLunchCell.h"
#import "DCProgramHeaderCellView.h"

#import "DCProgram+DC.h"
#import "DCEvent+DC.h"
#import "DCType+DC.h"
#import "DCTimeRange+DC.h"
#import "DCTime+DC.h"
#import "DCMainProxy+Additions.h"

#import "NSArray+DC.h"

@interface DCProgramItemsViewController ()

@property (nonatomic, weak) IBOutlet UITableView *tablewView;

@end

@implementation DCProgramItemsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _events = [[DCMainProxy sharedProxy] programEventsForDayNum:self.pageIndex];
    NSArray * a = [[DCMainProxy sharedProxy] uniqueTimeRangesForDayNum:self.pageIndex];
    NSArray * b = [_events eventsForTimeRange:a[0]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdSpeech = @"ProgramCellIdentifierSpeech";
    NSString *cellIdSpeechOfDay = @"ProgramCellIdentifierSpeechOfDay";
    NSString *cellIdCoffeBreak = @"ProgramCellIdentifierCoffeBreak";
    NSString *cellIdLunch = @"ProgramCellIdentifierLunch";
    
    DCProgram * event = _events[indexPath.row];
    UITableViewCell *cell;

    switch ([event.type.typeID integerValue]) {
        case DC_EVENT_SPEACH: {
            NSLog(@"CelId: %@", cellIdSpeech);
            DCSpeechCell *_cell = (DCSpeechCell*)[tableView dequeueReusableCellWithIdentifier: cellIdSpeech];
            _cell.speakerLabel.text = event.speakers;
            _cell.experienceLevelLabel.text = event.level;
            _cell.trackLabel.text = event.track;
            _cell.nameLabel.text = event.name;
            cell = _cell;
            break;
        }
        case DC_EVENT_SPEACH_OF_DAY: {
            NSLog(@"CelId: %@", cellIdSpeechOfDay);
            DCSpeechOfDayCell *_cell = (DCSpeechOfDayCell*)[tableView dequeueReusableCellWithIdentifier: cellIdSpeechOfDay];
            _cell.speakerLabel.text = event.speakers;
            _cell.experienceLevelLabel.text = event.level;
            _cell.trackLabel.text = event.track;
            _cell.nameLabel.text = event.name;
            cell = _cell;
            break;
        }
        case DC_EVENT_COFEE_BREAK: {
            NSLog(@"CelId: %@", cellIdCoffeBreak);
            DCCofeeCell *_cell = (DCCofeeCell*)[tableView dequeueReusableCellWithIdentifier: cellIdCoffeBreak];
            _cell.startLabel.text = @"n/a";
            _cell.startLabel.text = @"n/a";
            cell = _cell;
            break;
        }
        case DC_EVENT_LUNCH: {
              NSLog(@"CelId: %@", cellIdLunch);
            DCLunchCell *_cell = (DCLunchCell*)[tableView dequeueReusableCellWithIdentifier: cellIdLunch];
            _cell.startLabel.text = @"n/a";
            _cell.startLabel.text = @"n/a";
            cell = _cell;
            break;
        }
        default:
            break;
    }

    
    //Selection style
    /*
     UIView *selectedBackgroundView = [[UIView alloc] initWithFrame: cell.bounds];
     selectedBackgroundView.backgroundColor = [UIColor colorWithRed: 52./255. green: 52./255. blue: 59./255. alpha: 1.0];
     cell.selectedBackgroundView = selectedBackgroundView;
     */
    return cell;
}

-(BOOL) headerNeededInSection: (int) section
{
    /*lets check if this date range contains some events that need a time period header, DCSpeechCelll and DCSPeechofTheDayCell, if its only coffe breaks or lunch - we dont display a header*/
    BOOL headerNeeded = NO;
    for(DCProgram *event in _events) {
        if([event.type.typeID integerValue] == DC_EVENT_SPEACH || [event.type.typeID integerValue] == DC_EVENT_SPEACH_OF_DAY) {
            headerNeeded = YES; break;
        }
    }
    return headerNeeded;
}


-(UIView*) tableView: (UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    /*
    DCProgramHeaderCellView *headerViewCell = (DCProgramHeaderCellView*)[tableView dequeueReusableCellWithIdentifier: @"ProgramCellHeaderCell"];
    
//    lets check if this date range contains some events that need a time period header, DCSpeechCelll and DCSPeechofTheDayCell, if its only coffe breaks or lunch - we dont display a header
    BOOL headerNeeded = [self headerNeededInSection: section];
    NSDictionary *rangeDict = [[DCProgramsDataSourceMananger shared] dictionaryContatiningRangeAndArrayOfEventsInDay:self.pageIndex section: section];
    if(headerNeeded) {
        headerViewCell.startLabel.text = rangeDict[@"from"];
        headerViewCell.endLabel.text = rangeDict[@"to"];
        return headerViewCell;
    }
    */
    UIView *v = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 0.0)];
     v.backgroundColor = [UIColor whiteColor];
    return v;
}

-(CGFloat) tableView: (UITableView*) tableView heightForHeaderInSection:(NSInteger)section {
    BOOL headerNeeded = [self headerNeededInSection: section];
    return headerNeeded ? 97 : 1.0;
}

-(CGFloat)  tableView: (UITableView*) tableView heightForFooterInSection:(NSInteger)section {
    return 1.0;
}

- (NSString*) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger)section
{
        return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
/*
    DCEvent *event = [[DCProgramsDataSourceMananger shared] eventForSection:indexPath.section row: indexPath.row inDay: self.pageIndex];
    
    switch (event.eventType) {
        case DC_EVENT_SPEACH: {
            return 97;
            break;
        }
        case DC_EVENT_SPEACH_OF_DAY: {
            return 97;
            break;
        }
        case DC_EVENT_COFEE_BREAK: {
            return 94;
            break;
        }
        case DC_EVENT_LUNCH: {
            return 94;
            break;
        }
    }
 */
    return 94;
}

-(void) dealloc {
    
}

@end
