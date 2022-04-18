
<!-- README.md is generated from README.Rmd. Please edit that file -->

![](www/ka_logo.jpg)

# Dynamic Credit Risk Modeling

<!-- badges: start -->
<!-- badges: end -->

The goal of this repository is to serve as a resource for developing
robust credit risk models. Ideally, this repository will include
detailed documentation, resources, and examples (in `R`) related to
building such models.

## The Current State of Credit Risk Models

There are many shortcomings with current approaches to modeling credit
risk using traditional methods (e.g., logistic regression), particularly
as it fits into the lending decision itself. More specifically, these
methods lack the ability to:

-   handle heterogeneity
-   incorporate longitudinal history
-   forecast risk over time
-   dynamically update risk estimates

### Longitudinal History & Heterogeneity in the Data

Traditional frequentist statistical modeling approaches (logistic
regression, linear regression, etc.) and machine learning algorithms
(decision trees, neural networks, etc.) assume that each observation in
the dataset is independent; in other words, no two observations should
be from the same “group”. This is severely limiting because it often
causes us to have to aggregate our data “up” to a higher level, such
that we have a single observation in our training data for each subject
(depending on your methodology, the *subject* might be a loan, or a
customer). In doing so, we lose a lot of valuable information related to
the lifecycle of that subject, and we have less data available to train
the model. This same concept can be explained through the mathematical
principle of *homogeneity*, which requires that there are no
“sub-groups” within the model training data. Conversely, *heterogeneity*
refers to the presence of such “sub-group” in a population (e.g., having
multiple observations of the same loan or customer across multiple time
points).

We argue that it would be greatly beneficial to be able to include
additional history about a *subject* when training a credit decision
model, particularly models that are dependent on **default** as the
outcome variable.

### Forecasting Risk Over Time

Another shortcoming of approaches like logistic regression is that the
model output does not vary over a time horizon. This is unfortunate,
because we would expect that it takes time for default to occur. As an
example, a customer who is newly issued a 5-year term loan may have
current balance sheet with strong capital reserves to make the first
years’ worth of payments, but future cash flow issues the customer faces
may cause the business to default two or three years into the note. Like
with any forecast, as we look further and further into the future, we
should expect an increasing amount of uncertainty around our
predictions. Such risk should be priced according to the level of
uncertainty, and models that cannot estimate probability *over a
forward-looking time horizon* make it impossible to do so.

### Making Risk Estimates Dynamic

When using “traditional” modeling methods, we are often limited to using
independent variables that represent the *earliest* data point we have
in our database for that subject. This is due to the initial aggregation
of the data during model training (as discussed
[above](#longitudinal-history--heterogeneity-in-the-data)). In practice,
this means that all independent variables which are *random* (i.e, a
measurement that should change over time, such as *debt coverage ratio*
or *credit score*) – as opposed to *fixed* (e.g., *industry*, *state /
country*, etc.) – end up representing that measurement at loan
origination. Further, because these independent variables are
origination-specific, the predictions for a single subject will be
*static*; we do not have the ability to update our prediction for the
subject, even as we receive new data about that subject over time.
Ideally, we would like to be able to continuously, dynamically update
our estimated risk for a single subject every time we receive new data
(e.g., an updated *credit score*) about that subject.

## Approaches for Building Better Credit Risk Models

### Aggregated Loss Curves

Though the goal is typically to be able to build models that score
individual observations at the *subject*-level, sometimes it is not
possible to do so due to the available data or nature of the dependent
variable (e.g., the thing we are trying to predict). In this case,
taking a more aggregated approach can be the most appropriate course of
action. We suggest that building **loss curves** segmented by *product*
or *industry*, for example, is one best-practice approach.

<details>
<summary>
Resources
</summary>

-   <https://mc-stan.org/users/documentation/case-studies/losscurves_casestudy.html>

</details>

### Hierarchical Models

### Survival Models

#### Hierarchical Survival Models

### Joint Models

<details>
<summary>
Resources
</summary>

-   <https://cran.r-project.org/web/packages/rstanarm/vignettes/jm.html>

</details>
