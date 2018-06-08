MONARC Changelog
================

## 2.4.2 (2018-06-08)

### Enhancement

- improvements for the breadcrumb used in the graphs of the dashboard. Moreover
  it is now possible to click in the items of the breadcrumb in order to
  navigate between the different graph's levels;
- the deadlines of recommendations are now set with a date picker in the fourth
  step (#98);
- Removed the filter on the checkbox of the step 3 to display the dashboard of
  residual risk (#99);
- the column 'phone' has been removed from the 'users' table and in the models.
  The application must store the minimum amount of information required on
  users;
- Validate recommendations for operational risks (#102);
- the translations have been improved.

### Fix

- Operational risks are not updated (#93);
- In the 4th deliverable, an inherited risk is displayed at -1 and in red
  color (#100);
- Fixed a problem with some translations in the legends of the report's graphs;
- Removal of a recommendation on same risk of different assets of the same type
  (#92).


## 2.4.1 (2018-05-30)

### Enhancement

- the dashboard has been improved with more interactive graphs;
- the dashboard view is now part of the analysis. The home page of MONARC
  simply lists the projects.

### Fix

- Removal of a recommendation on same risk of different asset of the same type
  (#92);
- Order of operational risks (#88).


## 2.4.0 (2018-05-14)

### New

- the dashboard of MONARC has been entirely revamped and is now using D3.js;
- the version of MONARC is specified in all exported objects.

### Fix

- restart from an existing analysis (#87);
- order of operational risks (#88).


## 2.3.0 (2018-04-27)

### New

- an administrator of a MONARC front office instance is now able to set custom
  templates for deliveries per step.

### Enhancement

- default deliveries templates were improved;
- the section dedicated to the management of the organization has been moved in
  a dedicated view;
- improved the switching between the different available languages;
- improved the generation of the deliveries.

### Fix

- fixed a bug in the generation of the deliveries (#84);
- Inconsistency of Threat and Vulnerability Tables (#82);
- various minor fixes.


## 2.2.1 (2018-02-14)

### Enhancement

- Lack of information in the final deliverable (#65)
- Update template of third deliveries

### Fix

- CID/CIA translation in generateImpactsAppreciation for the deliveries
  (zm-client/#3)
- Removed useless dependencies to City entity.


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
