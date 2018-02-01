MONARC Changelog
================

## 2.2.0 (2018-02-01)

### New

- generate deliverable on 4th step of method (#51)
- export all of risk analysis data (#28)

### Enhancement

- option of export tables in a csv file (#52)
- show version MONARC on left panel (#50)
- ensures new users (of the back office) are created with a level of
  permissions (#48)
- the back office displays the appropriate view based on the user permissions
  (#48)
- set the selected attribute for the search filter of models in the back office

### Fix

- user operational risk - tag (#55)
- operational risk - tag (#54)
- detach a tag from an asset (#53)
- operational risk importation (#64)
- various minor fixes in the back office (management of models)


To update, check out our
[update](http://monarc.lu/technical-guide/#monarc-update) instructions.

This release includes a consequent changes in the database of the back office
and in the synchronization process of the deliveries templates (between the
back office and the different clients instances). If you are using a back
office, be careful to also update your ansible playbook
([instructions](http://monarc.lu/technical-guide/#update-monarc-when-connected-to-a-back-office)).


## 2.1.0 (2017-12-04)

### Enhancement

- cleaning of the initial database structure.
- split database model and data.
- simplify the panel to create new MONARC clients.
- improved the table of MONARC clients of the administration panel.
- removed all useless column of the 'clients' table.
- removed cities and countries tables in the database.
- added a condition to hide/show probability field on Threats assessment.
- it is now possible to export a whole analysis (or an asset) in JSON or as an
  encrypted JSON file. Analysis exported with the legacy system can still be
  imported in MONARC (#47).
- it is now mandatory to specify a level of permissions when creating a new
  user.

### Fix

- minor fixes in the forms of the user profile page.
- minor translations fixes.
- fixed a bug that prevented users to update password without the
  password recovery feature.


## 2.0.4 (2017-10-27)

### Fix

- fix a bug with salted passwords that prevented users to update their
  password. Users may have to use the password recovery functionality (zm-core)
  Reported by Nicolas SCHWARTZ, Cyber Security Team of PwC Luxembourg.
- set default deliveries in english (zm-client);
- block the probability in the threat assessment in 1.2 of the method (ng-anr);


## 2.0.3 (2017-10-13)

### Fix

- set default deliveries in english.
- Set NewCenturySchlbk-Roman Imagick font.


## 2.0.2 (2017-10-10)

### New

- MONARC is now available in Dutch.

### Enhancement

- updated German translations.
- updated the font used for the images in the generated reports.
- minor improvements in the configuration.

### Fix

- Lost operational risk when importing from MONARC Common DB (#32)
- PHP Notice: Use of undefined constant i (#33)


## 2.0.1 (2017-08-28)

### Enhancement

- Auto-complete function in the creation of a specific risk (#29)
- Remove the category for operational risk (#26)
- update of the database
- the database of MONARC is now backed up before an upgrade

### Fix

- Import bug : Format of duedate in recomandation (#30)
- Problem when a label of an impact contains a character such as '&' or '%' (#24)
- Lost operational risks of assets in library after a snapshot (#25)
- Problem setting a comment in new scale row (#24)
- hash of users' passwords were exposed through the API as reported by
  Thomas LARCHER, Cyber Security Team of PwC Luxembourg.


## 2.0.0 (2017-08-07)

### Other

- initial release of the version 2.0.0 of MONARC;
- project source code is now hosted at https://github.com/monarc-project
