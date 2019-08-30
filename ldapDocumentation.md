# LDAP Authentification to the Risk Assessment Platform
Some organisation may prefer that the users of the risk assessment platform to authenticate with their internal LDAP server instead of MONARC's SQL database. This can, in some cases, allow the administrator to have a better control over the users.
This document explains the procedures of the LDAP authentification method by describing the configuration needed for both Monarc and the LDAP server.

Note that the ldap package for the corresponding PHP version must be installed.

### Installing ldap package for PHP
To install ldap package on a lamp  for PHP, follow these steps:

* *apt-get install php-ldap* to install the package
* *service apache2 restart* to restart the apache server
* Now ldap is installed.

### Adding an user from LDAP Server in MONARC
In order to log in with a user from LDAP Server, the user must be added to the MONARC Platform with the ldap connection option. A password will not be required for the user as the password in LDAP server will be used.

### Authentificating using the LDAP server
If the connecting user has the ldap connection option enabled, the platform will establish a connection with the LDAP server and firstly authentificate using the admin credentials specified in the configuration file (local.php). If the connection is established successfully, a query will be executed to search in the directory information tree for the entry with the corresponding email address. In the case where a unique entry is found, a second authentification will then be attempted with the credential entered in the MONARC platform. The procedues that follow are the same as normal authentification using the MONARC's SQL database.

###  MONARC's local configuration for LDAP authentification
The configuration of MONARC platform for LDAP authentification can be done in the local.php file. An array with key "ldap" can be added into the php array to specify the configuration needed. The following table shows the configurable fields and their corresponding key.

| Key | Description | Default Value |
| ------ | ----------- | ----------- |
| uri   | The URI of the LDAP server in the form ldap://hostname:port or ldaps://hostname:port for SSL encryption.  | ldap:/// (local LDAP server with default port)
| ldapOptProtocolVersion | Version of LDAP protocol used | 3 (LDAPv3)
| ldapOptReferrals | How the client library should handle Referrals returned by the server | 0 (Disabled)
| baseDN | The distinguished name of the base entry for the directory where LDAP query should start at | dc=monarc,dc=com
| adminDN | The distinguished name of the admin entry | An anonymous bind will be attempted if not found
| adminPassword | The password of the admin entry | An anonymous bind will be attempted if not found
| loginAttribute | The key of the field in LDAP directory matched with the login e-mail | mail

### Setting up an OpenLDAP server on Ubuntu for testing purpose
To setup an OpenLDAP server on Ubuntu (we will use slapd package here)
*    *sudo apt-get update*
*    *sudo apt-get install slapd ldap-utils*

You can then configure the LDAP server using the command below
*    *sudo dpkg-reconfigure slapd*

To check the base DIT used by the LDAP server (to be specified in baseDN in local.php)
*    *ldapsearch -H ldap:// -x -s base -b "" -LLL "namingContexts"*
The -H option is used to specify the address of LDAP server (ldap:// if the server is local) 
The -x option to specify that an anonymous connection is used and -s to specify that we will search from the base
The attribute "namingContexts" is the attribute for the base entry of the DIT 

To add an entry in the LDAP Server, first copy this into a file with .ldif extension (test.ldif for example):


```
## FIRST Level hierarchy - people 
## uses mixed upper and lower case for objectclass
# this is an ENTRY sequence and is preceded by a BLANK line

dn: ou=people, dc=example,dc=com
ou: people
description: All people in organisation
objectclass: organizationalunit

## SECOND Level hierarchy
## ADD a single entry under FIRST (people) level
# this is an ENTRY sequence and is preceded by a BLANK line
# the ou: Human Resources is the department name

dn: cn=Robert Smith,ou=people,dc=example,dc=com
objectclass: inetOrgPerson
cn: Robert Smith
cn: Robert J Smith
cn: bob  smith
sn: smith
uid: rjsmith
userpassword: rJsmitH
carlicense: HISCAR 123
homephone: 555-111-2222
mail: r.smith@example.com
mail: rsmith@example.com
mail: bob.smith@example.com
description: swell guy
ou: Human Resources
```

Then use the follow command to add the entry into the LDAP server :
*ldapmodify -H ldap:// -x -D "cn=admin,dc=example,dc=com" -w password -a -f /path/to/test.ldif*

The option -D is to specify the entry to authenticate with, optin -w let you specify the admin's password and -a is for specifying that the entry should be added instead of modified

To add a password to the created entry:

*ldappasswd -H ldap:// -x -D "cn=admin,dc=example,dc=com" -w password  -S "uid==Robert Smith,ou=people,dc=example,dc=com"*

You can now create the user (without a password) on Monarc plateform with ldap connection enabled and the authentification should be successful.



