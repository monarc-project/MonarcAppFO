MONARC Changelog
================

## 2.9.5 (2019-12-18)

### Fix

- Fixed the creation of the snapshots with empty comment.
- Fixed the library categories management (creation of the new ones under root and sub categories).
([#212](https://github.com/monarc-project/MonarcAppFO/issues/216));

## 2.9.4 (2019-12-11)

### Fix

- Users anrs permissions are not revocable / snapshots are displayed in the list
  ([#215](https://github.com/monarc-project/MonarcAppFO/issues/215));
- Drag and drop recommendations: fixes recommendations ordering
  ([#206](https://github.com/monarc-project/MonarcAppFO/issues/206)).


## 2.9.3 (2019-12-09)

### Fix

- Configuration menu should not be scrollable
  ([#212](https://github.com/monarc-project/MonarcAppFO/issues/212));
- The type hint of parameter "theme" in method "setTheme" is invalid
  ([#211](https://github.com/monarc-project/MonarcAppFO/issues/211));
- Training VM does not show version number
  ([#210](https://github.com/monarc-project/MonarcAppFO/issues/210));
- library object duplicated
  ([#208](https://github.com/monarc-project/MonarcAppFO/issues/208));
- Drag and drop recommendations
  ([#206](https://github.com/monarc-project/MonarcAppFO/issues/206));
- Edit an asset in the library
  ([#205](https://github.com/monarc-project/MonarcAppFO/issues/205)).


## 2.9.2 (2019-11-25)

### Fix

- set composer.json to use dev-master instead of using fixed tag.


## 2.9.1 (2019-11-19)

### Enhancement

- the backend of MONARC is now using Zend Framework 3
  ([#15](https://github.com/monarc-project/MonarcAppFO/issues/15));
- MONARC code has been restructured to comply with PSR-2 standard;
- updated the usage of the dependencies (Core and FrontOffice) from
  packagist.org;  
- default initialization of the set of recommendations
  ([#183](https://github.com/monarc-project/MonarcAppFO/issues/183)).

### Fix

- Error when importing OP risks with recommendation
  ([#191](https://github.com/monarc-project/MonarcAppFO/issues/191));
- fix editing of recommendations via the risk sheet
  ([#195](https://github.com/monarc-project/MonarcAppFO/issues/195));
- various fixes related to the management of recommendations and impact edition.


## 2.9.0 (2019-08-23)

### New

- each analysis can now integrate a record of processing activities in order
  to help you in your GDPR compliance efforts;
- it is now possible to create and manage set of recommendations via the
  knowledge base of a risk analysis. Like for the security referentials
  (introduced in version 2.8.0), MOSP can now be used in order to
  [share recommendations](https://objects.monarc.lu/schema/17).

### Fix

- Monarc 2.8.3 - invalid datetime format: 1292 [#179](https://github.com/monarc-project/MonarcAppFO/issues/179)
- various minor fixes and improvements.


## 2.8.3 (2019-07-26)

### Enhancement

- Some improvements in MOSP import
- Some improvements in 3rd deliverable

### Fix

- SOA is not imported [#166](https://github.com/monarc-project/MonarcAppFO/issues/166)
- Drag & drop in risk treatment plan fails after 1 change [#167](https://github.com/monarc-project/MonarcAppFO/issues/166)
- Underscore "\_" is not considered as a special character in password reset [#169](https://github.com/monarc-project/MonarcAppFO/issues/169)
- Error when duplicating object [#171](https://github.com/monarc-project/MonarcAppFO/issues/171)
- Add objects in model/anr from common DB [#172](https://github.com/monarc-project/MonarcAppFO/issues/172)
- Composed objects in the library->position [#174](https://github.com/monarc-project/MonarcAppFO/issues/174)
- Import analysis -> conflict on uuid on objects [#175](https://github.com/monarc-project/MonarcAppFO/issues/175)
- FO > Knowledge base > OP risks [#177](https://github.com/monarc-project/MonarcAppFO/issues/177)


## 2.8.2 (2019-05-28)

### New

- the MONARC core objects (assets, threats, vulnerabilities and risks) are now
  identified with UUIDs. We published the objects on the
  [MONARC objects sharing platform](https://objects.monarc.lu). Risks from
  the CASES models are also [available](https://objects.monarc.lu/schema/16);
- Assets, threats, vulnerabilities, risks and referentials can be imported
  in the knowledge base of your analysis from MOSP without leaving the MONARC
  user interface.

### Enhancement

- Adding referential afterwards does not update the knowledge base
  [#156](https://github.com/monarc-project/MonarcAppFO/issues/156).

### Fix

- Import analysis in 2.81, exported from 2.72, gives errors [#152](https://github.com/monarc-project/MonarcAppFO/issues/152);
- Edit label of added Referentials does not work [#153](https://github.com/monarc-project/MonarcAppFO/issues/153);
- Problem generating deliverable [#157](https://github.com/monarc-project/MonarcAppFO/issues/157);
- Categories are duplicated in import [#158](https://github.com/monarc-project/MonarcAppFO/issues/158);
- Getting prob & impacts on operational risks [#161](https://github.com/monarc-project/MonarcAppFO/issues/161).


## 2.8.1 (2019-04-24)

### New

- the dashboard can now be exported to a CSV file or to a presentation file (.pptx).

### Enhancement

- Improve the treatment of a risk [#114](https://github.com/monarc-project/MonarcAppFO/issues/114);
- Improve risk sheet screen [#139](https://github.com/monarc-project/MonarcAppFO/issues/139);
- the cartography in the dashboard has been improved.

### Fix

- Loss of recommendation link [#150](https://github.com/monarc-project/MonarcAppFO/issues/150).


## 2.8.0 (2019-03-01)

### New

- [management of multiple referentials](https://www.monarc.lu/news/2019/03/01/monarc-280-released#management-of-multiple-security-referentials);
- [mapping between security referentials](https://www.monarc.lu/news/2019/03/01/monarc-280-released#mapping-between-security-referentials);
- [improvements to the statement of applicability](https://www.monarc.lu/news/2019/03/01/monarc-280-released#improvements-to-the-statement-of-applicability);
- [batch import of objects](https://www.monarc.lu/news/2019/03/01/monarc-280-released#batch-import-of-objects);
- [improvements to the dashboard](https://www.monarc.lu/news/2019/03/01/monarc-280-released#improvements-to-the-dashboard);
- [MONARC Objects Sharing Platform](https://www.monarc.lu/news/2019/03/01/monarc-280-released#monarc-objects-sharing-platform);
- it is now possible to set a page for your terms of service when MONARC is used to provide a service.

### Fix

- Fixed an issue when deleting threat theme [#143](https://github.com/monarc-project/MonarcAppFO/issues/143)
- Improved the go back on risk sheet [#95](https://github.com/monarc-project/MonarcAppFO/issues/95)


## 2.7.4 (2018-11-27)

### Fix

- Fixed risk target calculation [199db6c](https://github.com/monarc-project/zm-core/commit/199db6c1a59fe6cfead19bcc63d99c0b52f711aa);
- Fixed a typo in SoaCategorySuperClass [ea72881](https://github.com/monarc-project/zm-core/commit/ea72881d6a99acb0b658d7cb17d02a9338da5116);
- Fixed an issue when operational raw risks are hidden before an import [f382c91](https://github.com/monarc-project/zm-client/commit/f382c91fe624ea12d0c5b67c897879c359f09dd8);
- Fixed some minor issues in the views [cbbd94e](https://github.com/monarc-project/ng-anr/commit/cbbd94e7a019e7fa7dd8acf11334e9d4290166a7);
- Fixed several bugs in the reports generation (in the PHPWord library) caused
  by special characters.


## 2.7.3 (2018-10-25)

### Enhancement

- added backend capability for the bulk creation of objects;
- various improvements and harmonization of the backend code;

### Fix

- Sort order for operational risks in final deliverable annex D (#111);
- Upload of template deliverable fails in Dutch (#141);
- SOA is now included in snapshots.


## 2.7.2 (2018-10-08)

### Fix

- MONARC is now compatible with PHP 7.2 (#89). Future MONARC virtual machines
  will be based on Ubuntu Bionic LTS;
- Reports not generated in user's language or selected templates (#129);
- All your rights have been revoked. Please contact the manager for your organization (#110);
- various improvements and minor fixes in the back end.


## 2.7.1 (2018-09-07)

### Enhancement

- inform user which rights he has on each risk analysis (#131);
- display read/write access of the currently connected user on the home page (list of analysis) (#130);
- improvements to the statement of applicability (SOA) module (speed improvements);
- minor improvements to the home page.

### Fix

- impossible to download a report when user has no wright access (#133);
- name of columns of the evaluation scales are not displayed when a user has not write access (#132).


## 2.7.0 (2018-08-22)

### New

- this release introduces the statement of applicability (SOA) module for your
  risk analysis. This is a first step towards the awaited [Statement of Applicability
  & Gap Analysis module](https://github.com/monarc-project/MonarcAppFO/wiki/feature-SOA&GAP)

### Fix

- Error in translation in sector 3 of Final report (#124);
- The management of the position in the library is not working (#123);
- Empty categories in the library (#122);
- Impossible to order the questions in the back oficce (#121);
- Hidden impacts function doesn't works (#119);
- Search and sort filter for import (#38).


## 2.6.0 (2018-07-20)

### New

- MONARC users who open the home page in the web interface will see an image
  in the bottom left corner with the text "up-to-date" in green, "update
  available" in orange or "security update available" in red.
  This will make outdated version more visible for users of MONARC. This
  version checking is performed thanks to a
  [dedicated service](https://version.monarc.lu/version/MONARC).

### Enhancement

- the import and export functions have been improved;
- creation of recommendation and missing field (#115);
- make an easy link to implement the recommendation directly from the risk view
  (#112).

### Fix

- fixed a bug in the table Risk treatment plan management.
- problem on date parsing with the date-picker with non-US browsers (when using
  date.toLocaleString) (#117)
- it is not possible to reset the ``duedate`` attribute of a recommendation
  since the introduction of the date-picker (#116)
- review and correct the functionality of import by fusion or merge (#62)
- minor translations fixes.


## 2.5.0 (2018-07-04)

### New

- all dashboard data can now be exported to a CSV file with tabs;
- fine grained export of risk analysis (choice between method steps,
  interviews, existing controls and recommendations);
- it is now possible to create a new recommendation from an existing one;
- account deletion / right to erasure (#109).

### Enhancement

- how to erase the evaluation of all threats of a risk analysis (#97);
- the risk treatment view has been improved (#96);
- MONARC and the back office are now using AngularJS 1.7.0.

### Fix

- impossible to edit some fields in BO. Only is possible in the default
  language of instance (#108);
- md-datepicker sends the day before the one that was selected (#105);
- the filter by tag is not working on Knowledge base > Operational Risk (#103);
- the generation of deliverables has been improved (bullet point lists) (#101);
- various minor improvements and fixes in the back office of MONARC.


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
