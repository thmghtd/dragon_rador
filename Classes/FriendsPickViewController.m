//
//  FriendsPickViewController.m
//  DragonRador
//
//  Created by Motohiro Takayama on 6/14/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "FriendsPickViewController.h"
#import "DragonRador.h"
#import "TwitterFriends.h"
#import "AppDelegate.h"
#import "MySelf.h"
#import "Friend.h"

@interface FriendsPickViewController (Private)
- (UIImage *) getIcon:(NSDictionary *)user;
@end // FriendsPickViewController (Private)

@implementation FriendsPickViewController

#pragma mark ViewController

- (void)viewDidLoad
{
   [super viewDidLoad];
   UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
   self.navigationItem.leftBarButtonItem = backButton;
   [backButton release];

   AppDelegate *app = [UIApplication sharedApplication].delegate;
   my_self = app.my_self;
   twitter_friends = [[my_self twitterFriends] retain];
}

- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return twitter_friends.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   static NSString *CellIdentifier = @"FriendsPickViewCell";

   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
   }
   cell.accessoryType = UITableViewCellAccessoryNone;

   NSDictionary *user = [twitter_friends objectAtIndex:indexPath.row];
   Friend *friend = [[[Friend alloc] initWithName:[user objectForKey:@"screen_name"]] autorelease];
   UIImage *img = [self getIcon:user];
   cell.imageView.image = img;
   cell.textLabel.text = friend.name;

   if ([my_self.friends containsObject:friend])
      cell.accessoryType = UITableViewCellAccessoryCheckmark;

   return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   NSDictionary *user = [twitter_friends objectAtIndex:indexPath.row];
   NSString *friend_name = [user objectForKey:@"screen_name"];
   Friend *friend = [[[Friend alloc] initWithName:friend_name] autorelease];
   friend.image_url = [user objectForKey:@"image_url"];

   UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

   if ([my_self.friends containsObject:friend]) {
      [my_self.friends removeObject:friend];
      cell.accessoryType = UITableViewCellAccessoryNone;
   } else  {
      [my_self.friends addObject:friend];
      cell.accessoryType = UITableViewCellAccessoryCheckmark;
   }

   //[[NSUserDefaults standardUserDefaults] setObject:my_self.friends forKey:DR_FRIENDS];
}

#pragma mark others
- (void)dealloc
{
   [twitter_friends release];
   [super dealloc];
}

- (void) done
{
   [self dismissModalViewControllerAnimated:YES];  
}

@end

@implementation FriendsPickViewController (Private)

- (UIImage *) getIcon:(NSDictionary *)user
{
   NSURL *url = [NSURL URLWithString:[user objectForKey:@"image_url"]];

   NSURLRequest *req = [NSURLRequest requestWithURL:url];
   NSURLResponse *res = nil;
   NSError *err = nil;
   NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&err];
   if (err) {
      NSLog(@"error: %@", [err localizedDescription]);
   }
   UIImage *img = [UIImage imageWithData:data];
   return [img retain];
}

@end
