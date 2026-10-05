# GUY privacy policy

GUY is a personal desktop assistant that runs entirely on your own computer. There is no GUY server,
and its developer never receives any of your data.

## Google Calendar

When you link a Google account with `guy --add-calendar`, GUY asks Google for permission to see and
edit the events in your calendars (`calendar.events`), and for your email address (to know which
account was linked).

- GUY uses that access only to do what you ask it to: add events, list upcoming events, and remove
  events you ask it to remove.
- Your calendar data goes directly between your computer and Google, and is never sent to the
  developer. When you ask GUY's AI assistant about your calendar (which runs on Anthropic's Claude),
  the events it reads to answer you are sent to Anthropic for that answer, under your own Claude
  account.
- GUY's sign-in token is stored in your computer's keyring. Nothing is uploaded or shared.
- To revoke GUY's access, run `guy --remove-calendar you@gmail.com`, or remove GUY at
  [myaccount.google.com/permissions](https://myaccount.google.com/permissions).

GUY's use of information received from Google APIs adheres to the
[Google API Services User Data Policy](https://developers.google.com/terms/api-services-user-data-policy),
including the Limited Use requirements.

## Contact

dongy380@gmail.com
