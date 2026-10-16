# Contributing to MONARC

Thank you for your interest in contributing to MONARC.

Contributions are welcome through GitHub Pull Requests. If you do not have write access to the MONARC repository, please use the fork-based workflow described below.

## 1. Fork the repository

Open the MONARC repository on GitHub and click **Fork** to create a copy of the repository under your GitHub account or organization.

Clone your fork locally:

```bash
git clone https://github.com/<your-username>/MonarcAppFO.git
cd MonarcAppFO
```

Add the official MONARC repository as the `upstream` remote:

```bash
git remote add upstream https://github.com/monarc-project/MonarcAppFO.git
```

You can verify the configured remotes with:

```bash
git remote -v
```

## 2. Synchronise your fork

Before starting new work, synchronise your local repository with the latest version of the upstream repository:

```bash
git fetch upstream
git checkout master
git merge upstream/master
```

Then update your fork:

```bash
git push origin master
```

## 3. Create a branch

Create a dedicated branch for your contribution instead of working directly on `master`:

```bash
git checkout -b feature/my-contribution
```

Use a meaningful branch name describing the change, for example:

```text
feature/openshift-support
feature/helm-chart
fix/docker-permissions
```

## 4. Implement and test your changes

Make the required changes and test them locally whenever possible.

Please try to:

- keep changes focused on a single purpose;
- follow the existing project structure and coding conventions;
- avoid unrelated formatting or refactoring;
- update documentation when the behaviour or deployment process changes;
- ensure that existing functionality remains compatible whenever possible.

Commit your changes with a clear commit message:

```bash
git add .
git commit -m "Add OpenShift-compatible container configuration"
```

## 5. Push your branch

Push the branch to your fork:

```bash
git push origin feature/my-contribution
```

## 6. Create a Pull Request

On GitHub, create a Pull Request from your branch to the official MONARC repository.

The Pull Request should target:

```text
monarc-project/MonarcAppFO
```

and normally the `master` branch unless otherwise agreed with the MONARC maintainers.

In the Pull Request description, please explain:

- the purpose of the contribution;
- the main changes introduced;
- how the changes were tested;
- any compatibility or deployment considerations;
- any related issue, if applicable.

For larger changes, architectural changes, or new deployment approaches, we recommend opening an issue or discussing the proposal with the MONARC maintainers before implementation.

## 7. Review and integration

The MONARC maintainers will review the Pull Request and may request changes or additional information.

Once the review is completed and the contribution is accepted, the Pull Request will be merged into the MONARC repository by a maintainer.

Thank you for contributing to MONARC!
