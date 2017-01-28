//
//  CountryPickerViewController.m
//  CountryPickerDemo
//
//  Created by Theodore Gonzalez on 1/15/17.
//
//

#import "CountryPickerViewController.h"
#import "CountryTableViewCell.h"
#import "CountryPicker.h"
#import "CountryModel.h"
#define LangId @"en_US"  //change Localized country from here for Egypt  set LangId as @"ar_EG"


@interface CountryPickerViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tv;
@property (nonatomic) NSMutableArray *countryModels;
@end

@implementation CountryPickerViewController
static NSDictionary *dialCode;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tv registerNib:[UINib nibWithNibName:@"CountryTableViewCell" bundle:nil] forCellReuseIdentifier:@"CountryTableViewCell"];
}
#pragma mark - Data
+ (NSArray *)countryNames
{
    static NSArray *_countryNames = nil;
    if (!_countryNames)
    {
        _countryNames = [[[[self countryNamesByCode] allValues] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] copy];
    }
    return _countryNames;
}

+ (NSArray *)countryCodes
{
    static NSArray *_countryCodes = nil;
    if (!_countryCodes)
    {
        _countryCodes = [[[self countryCodesByName] objectsForKeys:[self countryNames] notFoundMarker:@""] copy];
    }
    
    return _countryCodes;
}
+ (NSDictionary *)diallingCodes
{
    static dispatch_once_t onceToken;
    
    dispatch_once (&onceToken, ^{
        // Do some work that happens once
        NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"DiallingCodes" ofType:@"plist"];
        dialCode = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    });
    
    return dialCode;
}
+ (NSDictionary *)countryNamesByCode
{
    static NSDictionary *_countryNamesByCode = nil;
    if (!_countryNamesByCode)
    {
        NSMutableDictionary *namesByCode = [NSMutableDictionary dictionary];
        for (NSString *code in [NSLocale ISOCountryCodes])
        {
            NSString *countryName = [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:code];
            
            //workaround for simulator bug
            if (!countryName)
            {
                countryName = [[NSLocale localeWithLocaleIdentifier:LangId] displayNameForKey:NSLocaleCountryCode value:code];
            }
            NSArray *unknownCodes = @[@"BV",@"BQ",@"CX",@"CC",@"CW",@"TF",@"GG",@"HM",@"IM",@"JE",@"YT",@"NF",@"PN",@"BL",@"MF",@"GS",@"SS",@"SJ",@"TL",@"UM",@"EH"];
            if ([unknownCodes containsObject:code] == NO) {
                namesByCode[code] = countryName ? countryName: code;
            }
        }
        _countryNamesByCode = [namesByCode copy];
    }
    return _countryNamesByCode;
}
- (NSMutableArray *)countryModels
{
    if (!_countryModels) {
        NSMutableDictionary *namesByCode = [NSMutableDictionary dictionary];
        _countryModels = [NSMutableArray new];
        
        for (NSString *code in [NSLocale ISOCountryCodes])
        {
            NSString *countryName = [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:code];
            
            //workaround for simulator bug
            if (!countryName)
            {
                countryName = [[NSLocale localeWithLocaleIdentifier:LangId] displayNameForKey:NSLocaleCountryCode value:code];
            }
            NSArray *unknownCodes = @[@"BV",@"BQ",@"CX",@"CC",@"CW",@"TF",@"GG",@"HM",@"IM",@"JE",@"YT",@"NF",@"PN",@"BL",@"MF",@"GS",@"SS",@"SJ",@"TL",@"UM",@"EH"];
            if ([unknownCodes containsObject:code] == NO) {
                CountryModel *model = [CountryModel new];
                model.name = countryName ?: code;
                model.code = code;
                model.phoneExtension = [[self class] diallingCodes][code.lowercaseString];

                [_countryModels addObject:model];
            }
        }
    }
    return _countryModels;
}
+ (NSDictionary *)countryCodesByName
{
    static NSDictionary *_countryCodesByName = nil;
    if (!_countryCodesByName)
    {
        NSDictionary *countryNamesByCode = [self countryNamesByCode];
        NSMutableDictionary *codesByName = [NSMutableDictionary dictionary];
        for (NSString *code in countryNamesByCode)
        {
            codesByName[countryNamesByCode[code]] = code;
            
        }
        _countryCodesByName = [codesByName copy];
    }
    return _countryCodesByName;
}
#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(__unused UITableView *)tableView numberOfRowsInSection:(__unused NSInteger)section {
    return (NSInteger)self.countryModels.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = (NSUInteger)indexPath.row;
    CountryModel *model = self.countryModels[row];
    
    UIImage *image;
    NSString *imagePath = [NSString stringWithFormat:@"CountryPicker.bundle/%@", model.code];
    if ([[UIImage class] respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)])
        image = [UIImage imageNamed:imagePath inBundle:[NSBundle bundleForClass:[CountryPicker class]] compatibleWithTraitCollection:nil];
    else {
        image = [UIImage imageNamed:imagePath];
    }
    
    CountryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CountryTableViewCell" forIndexPath:indexPath];
    cell.lbCountryCode.text = model.phoneExtension;
    cell.lbCountryName.text = model.name;
    cell.ivFlag.image       = image;
    return cell;
}
#pragma mark - UITableViewDelegate
-(void)tableView:(__unused UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = (NSUInteger)indexPath.row;
    CountryModel *model = self.countryModels[row];
    
    __strong id<CountryPickerViewControllerDelegate> strongDelegate = self.delegate;
    [strongDelegate countryPickerViewController:self didSelectCountryWithName:model.name code:model.code dialCode:model.phoneExtension];
}
@end
