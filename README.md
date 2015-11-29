### Learn To Code Workshop

Welcome to the Learn To Code Workshop. During the 4 days we are going to spend together we will explore some of the techniques professional developers are using
in their development process. The idea with this workshop is to showcase some of those techniques and put them in to practice.

The application we will build is a tool to administrate and validate course certificates.

##### Problem definition
**As a education institution/company I face a growing problem with aggregating course and student information
and issue appropriate course certificates. I also want to make sure that the certificates I issue are not tempered
with by bad people that want to take credit for a course they actually did not attend.**

What makes this application interesting as a learning experience is that it solves a relatively simple problem but requires implementation of several
technologies in order to be completed.
We are going to use:

- a database for storing data (PostgreSQL)
- data import functionality
- a back-end framework (Sinatra)
- a library to generate pdf-files
- a library to generate images
- an encryption library
- a cloud storage service (Amazon Web Services)
- a Platform as a Service provider (Heroku)
- email functionality and service to distribute documents (Gmail)
- JavaScript (jQuery) to add functionality and to enhance the user experience on the front-end
- a CSS framework (Foundation) to style the front-end
- and more...

We will be moving in a rather fast phase but we will take good time to explain everything we do. The most important thing is that you follow us as we move forward -
the best way to start to learn to code is.. to code! Even if you don't understand everything, we'd like you to do your best to actually go through the steps in the walkthroughs.
There's no bigger joy then see code you've written pass all the tests and come to life in your browser.

Tests? Yes, we will be practicing Behavior Driven Development with a mixin of unit tests to make sure that our application meets the requirements (more on that later).

Okay, moving on...

#### User stories

This User story format that we'll be using for describing out application focuses us on three important questions:

- Who's using the system?
- What are they doing?
- Why do they care?

#### User story format

```
  As a <role>
  So that/In order to <business value>
  I want to <feature>
```
##### User stories examples
These are some initial user stories that we will be working with. In a real project we would spend a few hours to a week defining user stories and breaking them down to features and scenarios.
For the purpose of ths exercise, we will add user stories along the way as we progress.

```
As a course administrator,
In order to be able to issue certificates,
I want to be able to create a course offering with a description and multiple delivery dates
```

```
As a course administrator,
In order to be able to issue the right certificates for a course,
I want to be able display course title, course date and the
participants name on the certificate
```

```
As a course administrator,
In order to be able to issue certificates to participants,
I want to be able import a list of participants with their final grades
```

```
As a course administrator,
In order to be able to issue certificates to participants,
I want to be able filter participants by their final grades
and generate certificates by predefined conditions.
```

```
As a course administrator,
In order to be able to issue the right certificates for a course,
I want to be able to use a predefined design template for the certificate
(I want to be able to upload and use a design template for the certificate)
```

```
As a course administrator,
In order to allow external users to verify the authenticity of a certificate I issued,
I want to include a verification url to the certificate
```

```
As a course administrator,
In order to know how often my verification system is being used
I want to track every call to a verification url
```

[Step 1](walkthroughs/step1.md)

![Logo](/walkthroughs/extras/images/logo-with-taglne_small.png?raw=true "Craft Academy by Pragmatic Sweden AB")

<a rel="license" href="http://creativecommons.org/licenses/by-nc/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc/4.0/88x31.png" /></a><br /><span xmlns:dct="http://purl.org/dc/terms/" property="dct:title">Learn To Code Workshop</span> by <span xmlns:cc="http://creativecommons.org/ns#" property="cc:attributionName">Pragmatic Sweden</span> is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc/4.0/">Creative Commons Attribution-NonCommercial 4.0 International License</a>.
