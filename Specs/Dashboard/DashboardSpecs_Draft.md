# MONARC Dashboard functional specifications

> Draft version. Pending for approval

## A. Purpose & objectives
{TODO}


## B. Functional specifications
### I. Backend
{TODO}
#### I.1) Scheduled job

#### I.2) Model extend

### II. Frontend
---
#### II.1) Overview
##### 11) Layout
##### 12) Components
###### 12a. Risks
###### 12b. Threats
###### 12c. Vulnerabilities
###### 12d. Cartography
---
#### II.2) Decision support
##### 21) Layout

{IMG PLACEHOLDER : main decision tab layout}

The decision support view must be composed of 2 areas splitting the available space at screen horizontally. It must be possible for the user to drag a delimiter between the two areas to cleansen the view.  
The 2 areas will both display a list of textual elements. These elements should be highlighted when clicked the first time.

{IMG PLACEHOLDER : individual list}

##### 22) Components
###### 22a. Custom action plan
The first component of the decision support tab is a priority queue concerning the recommandations done by the risk assessor.  
Indeed, one must have the ability to choose a strategy in a dropdown list and then be provided with different results. The available strategies are the following :
* Cost
* Time
* Quality
* Criticity
* Importance
* Likelihood

Each element of the list represents a measure which will be presented as following :

|#| Field1 | Field2 | Field3 | Field4 | Field5 |
|---|---|---|---|---|---|
|1| ExampleField1 | ExampleField2 | ExampleField3 | ExampleField4 | ExampleField5 |

About the different strategies that one must find in the dropdown list, they are described below :

| Strategy | Description | Score |
|---|---|---|
| Cost | Prioritize the cheapest mesures | = &#x2197; 0.75 x initial cost + 0.25 x maintenance  |
| Time | Put the recommandation that are the shortest to set up at the top of the queue | = &#x2197; time qualification  |
| Quality | Prioritize the measures which decrease the most the overall vulnerability | = &#x2198; &Sigma; ( Vuln before - Vuln after ) for each risk assigned to the recommandation |
| Criticity | Highlight the most spread measures among the organization's risks | = &#x2198; Number of risks mitigated  |
| Importance | Put in order according to the criteria of importance of the risk assessor | = &#x2198; Measure's importance criteria |
| Likelihood | Prioritize the measures that are related to the most likely risks | = &#x2198; &Sigma; ( Threat probability x Vulnerability qualification ) |


###### 22b. Risk factors
The second part of the decision support tab is about highlight specific aspect of the risk analysis that might stayed unoticed from the user otherwise.

> The application will only display the most significant risk amongst those shared by global assets

One must have to choose from a dropdown list the following options :
* Global risks
* Vulnerabilities
* Threats

Similarly to above, the application will give a score according to the chosen option and then list the results, which here will be different for each option.

Global risk element :

|#| Field1 | Field2 | Field3 | Field4 | Field5 |
|---|---|---|---|---|---|
|1| ExampleField1 | ExampleField2 | ExampleField3 | ExampleField4 | ExampleField5 |

Threat element :

|#| Field1 | Field2 | Field3 | Field4 | Field5 |
|---|---|---|---|---|---|
|1| ExampleField1 | ExampleField2 | ExampleField3 | ExampleField4 | ExampleField5 |

Vulnerability element :

|#| Field1 | Field2 | Field3 | Field4 | Field5 |
|---|---|---|---|---|---|
|1| ExampleField1 | ExampleField2 | ExampleField3 | ExampleField4 | ExampleField5 |

Here is how the score must be calculated for each option :

| Option | Description | Score | Order By |
|---|---|---|---|
| Global risks | Show risks that might be more present than the UI let see | &#x2198; number of asset which contain that risk | Current risk value |
| Threats | Highlight the most spread threats | &#x2198; number of asset concerned by the threat | Threat probability score |
| Vulnerabilities | Bring out the real weaknesses of the organisation | &#x2198; number of asset affected by the same vulnerability | Vulnerability |

---
#### II.3) Perspective
##### 31) Layout
{IMG PLACEHOLDER : perspective tab layout}

This last view of the dashboard is meant to compare two snapshot of the risk analysis : the one currently in use and another one that one must be able to load through an upload field.

This perspective view will then be composed of one plot, in which different bar charts will be nested.
In fact, the user must be given a checkbox from which he could choose what chart is revelant to him and display it.

{IMG PLACEHOLDER : example of 1 chart}

##### 32) Components
###### 32a. Evolutions & tendancies
The main plot area should not label any axis since informations presented are in different scales. Indeed, the values should be displayed directly on mouse hovering in a tooltip.
The values inside the checkbox should be filled with the following options :

| Value | Description |
|---|---|
| Aggregated Risks | Show the total risk number no matter their value |
| Splitted Risks | Show strong, medium and weak risks total number |
| Assets | Compare the number of assets present in the risk analysis |
| Applied recomandations | Bring out number of applied recommandations |
| Risk mean | Put in perspective the overall risk value for both risk analysis |

> Aggregated and splitted options shall be exclusive

---
