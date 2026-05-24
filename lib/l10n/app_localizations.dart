import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_sw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('sw'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Transformers Church'**
  String get appTitle;

  /// No description provided for @chapelName.
  ///
  /// In en, this message translates to:
  /// **'Transformers Chapel'**
  String get chapelName;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageSwahili.
  ///
  /// In en, this message translates to:
  /// **'Kiswahili'**
  String get languageSwahili;

  /// No description provided for @languageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Language updated'**
  String get languageUpdated;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'{feature} coming soon'**
  String comingSoon(String feature);

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get tabProgress;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @drawerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get drawerDashboard;

  /// No description provided for @drawerContribute.
  ///
  /// In en, this message translates to:
  /// **'Contribute'**
  String get drawerContribute;

  /// No description provided for @drawerMyProgress.
  ///
  /// In en, this message translates to:
  /// **'My Progress'**
  String get drawerMyProgress;

  /// No description provided for @drawerChurchProgress.
  ///
  /// In en, this message translates to:
  /// **'Church Progress'**
  String get drawerChurchProgress;

  /// No description provided for @drawerEditTarget.
  ///
  /// In en, this message translates to:
  /// **'Edit Target'**
  String get drawerEditTarget;

  /// No description provided for @drawerContributionHistory.
  ///
  /// In en, this message translates to:
  /// **'Contribution History'**
  String get drawerContributionHistory;

  /// No description provided for @drawerUpcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Events'**
  String get drawerUpcomingEvents;

  /// No description provided for @drawerShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get drawerShare;

  /// No description provided for @drawerNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get drawerNotifications;

  /// No description provided for @drawerSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get drawerSettings;

  /// No description provided for @drawerLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get drawerLogout;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get welcomeBack;

  /// No description provided for @contributionsMatter.
  ///
  /// In en, this message translates to:
  /// **'Your Contributions Matter'**
  String get contributionsMatter;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @couldNotLoadHome.
  ///
  /// In en, this message translates to:
  /// **'Could not load home'**
  String get couldNotLoadHome;

  /// No description provided for @couldNotLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Could not load profile'**
  String get couldNotLoadProfile;

  /// No description provided for @couldNotLoadProgress.
  ///
  /// In en, this message translates to:
  /// **'Could not load progress'**
  String get couldNotLoadProgress;

  /// No description provided for @contributionPageComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Contribution page coming soon'**
  String get contributionPageComingSoon;

  /// No description provided for @myProgress.
  ///
  /// In en, this message translates to:
  /// **'My Progress'**
  String get myProgress;

  /// No description provided for @raisedOfTarget.
  ///
  /// In en, this message translates to:
  /// **'raised of {target} target'**
  String raisedOfTarget(String target);

  /// No description provided for @goalAdjustedOn.
  ///
  /// In en, this message translates to:
  /// **'Goal adjusted on {date}'**
  String goalAdjustedOn(String date);

  /// No description provided for @contribute.
  ///
  /// In en, this message translates to:
  /// **'Contribute'**
  String get contribute;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @setContributionGoal.
  ///
  /// In en, this message translates to:
  /// **'Set contribution goal'**
  String get setContributionGoal;

  /// No description provided for @setContributionGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Set your contribution goal'**
  String get setContributionGoalTitle;

  /// No description provided for @setContributionGoalBody.
  ///
  /// In en, this message translates to:
  /// **'Choose a target amount so you can track progress and start contributing.'**
  String get setContributionGoalBody;

  /// No description provided for @startContributing.
  ///
  /// In en, this message translates to:
  /// **'Start contributing'**
  String get startContributing;

  /// No description provided for @startContributingBody.
  ///
  /// In en, this message translates to:
  /// **'Your goal is {target}. Make your first gift to begin tracking progress toward the target.'**
  String startContributingBody(String target);

  /// No description provided for @shareFundraiser.
  ///
  /// In en, this message translates to:
  /// **'Share fundraiser'**
  String get shareFundraiser;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @progressDemographics.
  ///
  /// In en, this message translates to:
  /// **'Demographics'**
  String get progressDemographics;

  /// No description provided for @progressMinistries.
  ///
  /// In en, this message translates to:
  /// **'Ministries'**
  String get progressMinistries;

  /// No description provided for @churchProgressEmptyDemographicTitle.
  ///
  /// In en, this message translates to:
  /// **'No demographic contributions yet'**
  String get churchProgressEmptyDemographicTitle;

  /// No description provided for @churchProgressEmptyDemographicBody.
  ///
  /// In en, this message translates to:
  /// **'Women, Men, and Youth totals will appear here once members in those groups start contributing.'**
  String get churchProgressEmptyDemographicBody;

  /// No description provided for @churchProgressEmptyMinistryTitle.
  ///
  /// In en, this message translates to:
  /// **'No ministry contributions yet'**
  String get churchProgressEmptyMinistryTitle;

  /// No description provided for @churchProgressEmptyMinistryBody.
  ///
  /// In en, this message translates to:
  /// **'Ministry team totals will show here once choirs, boards, and other teams begin giving.'**
  String get churchProgressEmptyMinistryBody;

  /// No description provided for @totalRaised.
  ///
  /// In en, this message translates to:
  /// **'Total raised'**
  String get totalRaised;

  /// No description provided for @totalRaisedLabel.
  ///
  /// In en, this message translates to:
  /// **'Total raised'**
  String get totalRaisedLabel;

  /// No description provided for @noContributionsYet.
  ///
  /// In en, this message translates to:
  /// **'No contributions yet'**
  String get noContributionsYet;

  /// No description provided for @groupsTracked.
  ///
  /// In en, this message translates to:
  /// **'Groups tracked'**
  String get groupsTracked;

  /// No description provided for @ministriesTracked.
  ///
  /// In en, this message translates to:
  /// **'Ministries tracked'**
  String get ministriesTracked;

  /// No description provided for @demographicsTrackedValue.
  ///
  /// In en, this message translates to:
  /// **'Women · Men · Youth'**
  String get demographicsTrackedValue;

  /// No description provided for @ministriesTrackedValue.
  ///
  /// In en, this message translates to:
  /// **'6 ministry teams'**
  String get ministriesTrackedValue;

  /// No description provided for @sectionAccount.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get sectionAccount;

  /// No description provided for @sectionChurchGroups.
  ///
  /// In en, this message translates to:
  /// **'CHURCH GROUPS'**
  String get sectionChurchGroups;

  /// No description provided for @sectionPreferences.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get sectionPreferences;

  /// No description provided for @sectionSupport.
  ///
  /// In en, this message translates to:
  /// **'SUPPORT'**
  String get sectionSupport;

  /// No description provided for @sectionAbout.
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get sectionAbout;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @demographic.
  ///
  /// In en, this message translates to:
  /// **'Demographic'**
  String get demographic;

  /// No description provided for @ministry.
  ///
  /// In en, this message translates to:
  /// **'Ministry'**
  String get ministry;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get notificationsEnabled;

  /// No description provided for @notificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get notificationsDisabled;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @helpSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'FAQs, contact us'**
  String get helpSupportSubtitle;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get appVersion;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @googleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in'**
  String get googleSignIn;

  /// No description provided for @setViaEmailLink.
  ///
  /// In en, this message translates to:
  /// **'Set via email link'**
  String get setViaEmailLink;

  /// No description provided for @passwordHidden.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get passwordHidden;

  /// No description provided for @editName.
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get editName;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @yourFullName.
  ///
  /// In en, this message translates to:
  /// **'Your full name'**
  String get yourFullName;

  /// No description provided for @editEmail.
  ///
  /// In en, this message translates to:
  /// **'Edit email'**
  String get editEmail;

  /// No description provided for @newEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'New email address'**
  String get newEmailAddress;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @emailUpdateHint.
  ///
  /// In en, this message translates to:
  /// **'We will send a confirmation link to your new address. Your sign-in email updates after you confirm.'**
  String get emailUpdateHint;

  /// No description provided for @emailConfirmationSent.
  ///
  /// In en, this message translates to:
  /// **'Confirmation email sent. Open the link to finish updating your email.'**
  String get emailConfirmationSent;

  /// No description provided for @phoneUpdated.
  ///
  /// In en, this message translates to:
  /// **'Phone number updated'**
  String get phoneUpdated;

  /// No description provided for @groupsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Church groups updated'**
  String get groupsUpdated;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordUpdated;

  /// No description provided for @passwordLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Check your email for the password link'**
  String get passwordLinkSent;

  /// No description provided for @editPhone.
  ///
  /// In en, this message translates to:
  /// **'Edit phone number'**
  String get editPhone;

  /// No description provided for @churchGroups.
  ///
  /// In en, this message translates to:
  /// **'Church groups'**
  String get churchGroups;

  /// No description provided for @churchGroupsHint.
  ///
  /// In en, this message translates to:
  /// **'Demographic group is required. Ministry is optional.'**
  String get churchGroupsHint;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get updatePassword;

  /// No description provided for @passwordChangeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password, then choose a new one (at least 8 characters).'**
  String get passwordChangeHint;

  /// No description provided for @passwordGoogleTitle.
  ///
  /// In en, this message translates to:
  /// **'Password & Google sign-in'**
  String get passwordGoogleTitle;

  /// No description provided for @passwordGoogleBody.
  ///
  /// In en, this message translates to:
  /// **'You sign in with Google, so there is no app password to edit here. We can email you a link to create a password for {email} if you also want email sign-in.'**
  String passwordGoogleBody(String email);

  /// No description provided for @setPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a password'**
  String get setPasswordTitle;

  /// No description provided for @setPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'This account does not have a password yet. We can email a link to {email} so you can set one.'**
  String setPasswordBody(String email);

  /// No description provided for @emailSetupLink.
  ///
  /// In en, this message translates to:
  /// **'Email me a setup link'**
  String get emailSetupLink;

  /// No description provided for @checkInboxPassword.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox for a link to set your password. You can close this and keep using Google sign-in.'**
  String get checkInboxPassword;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to access your account.'**
  String get logoutConfirmBody;

  /// No description provided for @demographicGroup.
  ///
  /// In en, this message translates to:
  /// **'Demographic group'**
  String get demographicGroup;

  /// No description provided for @demographicHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Women, Men, Youth'**
  String get demographicHint;

  /// No description provided for @ministryOptional.
  ///
  /// In en, this message translates to:
  /// **'Ministry (optional)'**
  String get ministryOptional;

  /// No description provided for @ministryNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get ministryNone;

  /// No description provided for @groupWomen.
  ///
  /// In en, this message translates to:
  /// **'Women'**
  String get groupWomen;

  /// No description provided for @groupMen.
  ///
  /// In en, this message translates to:
  /// **'Men'**
  String get groupMen;

  /// No description provided for @groupYouth.
  ///
  /// In en, this message translates to:
  /// **'Youth'**
  String get groupYouth;

  /// No description provided for @groupChoir.
  ///
  /// In en, this message translates to:
  /// **'Choir'**
  String get groupChoir;

  /// No description provided for @groupDeacons.
  ///
  /// In en, this message translates to:
  /// **'Deacon board'**
  String get groupDeacons;

  /// No description provided for @groupElders.
  ///
  /// In en, this message translates to:
  /// **'Elders'**
  String get groupElders;

  /// No description provided for @groupSanctuary.
  ///
  /// In en, this message translates to:
  /// **'Sanctuary keepers'**
  String get groupSanctuary;

  /// No description provided for @groupUshers.
  ///
  /// In en, this message translates to:
  /// **'Ushers'**
  String get groupUshers;

  /// No description provided for @groupMedia.
  ///
  /// In en, this message translates to:
  /// **'Media team'**
  String get groupMedia;

  /// No description provided for @passwordHintEight.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get passwordHintEight;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authWelcomeBack;

  /// No description provided for @authSignInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your journey with Transformers Chapel.'**
  String get authSignInSubtitle;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// No description provided for @authSignInGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get authSignInGoogle;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get authNoAccount;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccount;

  /// No description provided for @authOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get authOr;

  /// No description provided for @authCreateAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccountTitle;

  /// No description provided for @authCreateAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join Transformers Chapel and start your giving journey.'**
  String get authCreateAccountSubtitle;

  /// No description provided for @authFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get authFullName;

  /// No description provided for @authConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPassword;

  /// No description provided for @authSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authSignUp;

  /// No description provided for @authSignUpGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google'**
  String get authSignUpGoogle;

  /// No description provided for @authHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authHaveAccount;

  /// No description provided for @authSignInLink.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignInLink;

  /// No description provided for @authForgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotTitle;

  /// No description provided for @authForgotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a link to reset your password.'**
  String get authForgotSubtitle;

  /// No description provided for @authSendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get authSendResetLink;

  /// No description provided for @authBackToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get authBackToSignIn;

  /// No description provided for @authResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Set new password'**
  String get authResetTitle;

  /// No description provided for @authResetSubtitleWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter the reset code from the email sent to {email}, then choose a new password.'**
  String authResetSubtitleWithEmail(String email);

  /// No description provided for @authResetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the reset code from your email, then choose a new password.'**
  String get authResetSubtitle;

  /// No description provided for @authResetCode.
  ///
  /// In en, this message translates to:
  /// **'Reset code'**
  String get authResetCode;

  /// No description provided for @authPasswordUpdatedSignIn.
  ///
  /// In en, this message translates to:
  /// **'Password updated. You can sign in with your new password.'**
  String get authPasswordUpdatedSignIn;

  /// No description provided for @authOtpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your phone'**
  String get authOtpTitle;

  /// No description provided for @authOtpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to {phone}'**
  String authOtpSubtitle(String phone);

  /// No description provided for @authVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get authVerify;

  /// No description provided for @authResend.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get authResend;

  /// No description provided for @authResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String authResendIn(int seconds);

  /// No description provided for @authOtpFromRegister.
  ///
  /// In en, this message translates to:
  /// **'Open this screen from Create account to verify your phone.'**
  String get authOtpFromRegister;

  /// No description provided for @authOtpEnterSix.
  ///
  /// In en, this message translates to:
  /// **'Enter all 6 digits.'**
  String get authOtpEnterSix;

  /// No description provided for @authOtpResent.
  ///
  /// In en, this message translates to:
  /// **'A new code has been sent.'**
  String get authOtpResent;

  /// No description provided for @authPickGroupsTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your groups'**
  String get authPickGroupsTitle;

  /// No description provided for @authPickGroupsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your demographic group (required). Add a ministry if you serve on a team — for example Choir or Ushers.'**
  String get authPickGroupsSubtitle;

  /// No description provided for @authContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get authContinue;

  /// No description provided for @errorEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get errorEnterEmail;

  /// No description provided for @errorValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get errorValidEmail;

  /// No description provided for @errorEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get errorEnterPassword;

  /// No description provided for @errorPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get errorPasswordMinLength;

  /// No description provided for @errorConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get errorConfirmPassword;

  /// No description provided for @errorPasswordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get errorPasswordsMismatch;

  /// No description provided for @errorSomethingWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get errorSomethingWrong;

  /// No description provided for @errorWrongCredentials.
  ///
  /// In en, this message translates to:
  /// **'Wrong email or password'**
  String get errorWrongCredentials;

  /// No description provided for @errorAccountDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get errorAccountDisabled;

  /// No description provided for @errorSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed'**
  String get errorSignInFailed;

  /// No description provided for @errorGoogleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed'**
  String get errorGoogleSignInFailed;

  /// No description provided for @errorGoogleSignUpFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-up failed'**
  String get errorGoogleSignUpFailed;

  /// No description provided for @errorEnterName.
  ///
  /// In en, this message translates to:
  /// **'Enter at least 2 characters'**
  String get errorEnterName;

  /// No description provided for @errorSelectDemographic.
  ///
  /// In en, this message translates to:
  /// **'Select your demographic group'**
  String get errorSelectDemographic;

  /// No description provided for @errorValidMinistry.
  ///
  /// In en, this message translates to:
  /// **'Select a valid ministry'**
  String get errorValidMinistry;

  /// No description provided for @errorValidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get errorValidPhone;

  /// No description provided for @errorAlreadyYourEmail.
  ///
  /// In en, this message translates to:
  /// **'This is already your email'**
  String get errorAlreadyYourEmail;

  /// No description provided for @errorCurrentPasswordIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect'**
  String get errorCurrentPasswordIncorrect;

  /// No description provided for @errorChooseDifferentPassword.
  ///
  /// In en, this message translates to:
  /// **'Choose a different password'**
  String get errorChooseDifferentPassword;

  /// No description provided for @errorUseEightCharacters.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters'**
  String get errorUseEightCharacters;

  /// No description provided for @errorCouldNotUpdateName.
  ///
  /// In en, this message translates to:
  /// **'Could not update name. Try again.'**
  String get errorCouldNotUpdateName;

  /// No description provided for @errorCouldNotUpdateEmail.
  ///
  /// In en, this message translates to:
  /// **'Could not update email. Try again.'**
  String get errorCouldNotUpdateEmail;

  /// No description provided for @errorCouldNotUpdatePhone.
  ///
  /// In en, this message translates to:
  /// **'Could not update phone. Try again.'**
  String get errorCouldNotUpdatePhone;

  /// No description provided for @errorCouldNotUpdateGroups.
  ///
  /// In en, this message translates to:
  /// **'Could not update groups. Try again.'**
  String get errorCouldNotUpdateGroups;

  /// No description provided for @errorCouldNotUpdatePassword.
  ///
  /// In en, this message translates to:
  /// **'Could not update password. Try again.'**
  String get errorCouldNotUpdatePassword;

  /// No description provided for @errorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'That email is already in use'**
  String get errorEmailInUse;

  /// No description provided for @errorRecentLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Please sign out, sign in again, then try again'**
  String get errorRecentLoginRequired;

  /// No description provided for @errorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak'**
  String get errorWeakPassword;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
