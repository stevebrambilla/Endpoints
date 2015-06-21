# Endpoints

Swift one-way bindings between ReactiveCocoa SignalProducers and views.

A work-in-progress.

**Example** — Reading values from text fields and combining them:
``` swift
// Allow logging in when a username and password have been entered and no 
// account is currently logged in.
let canLogIn = MutableProperty(false)
canLogIn <~ combineLatest(usernameTextField.textProducer(), passwordTextField.textProducer(), LoginManager.loggedIn.producer)
    |> map { (username, password, loggedIn) in
        return count(username) > 0 && count(password) > 0 && !loggedIn
    }
```

**Example** — Binding a signal producer to an activity indicator:
``` swift
// Animate the Loading indicator while logging in OR logging out.
let isLoading = combineLatest(logInAction.executing.producer, logOutAction.executing.producer)
    |> map { (loggingIn, loggingOut) in 
        return loggingIn || loggingOut
    }
disposable += activityIndicator.animatingEndpoint.bind(isLoading)
```

**Example** —Binding an action to a button:
``` swift
// Executes `logOutAction` when tapped, ignoring the 'sender' by sending () as 
// the Action's input.
disposable += logOutButton.executor
    .ignoreEvents()
    .bind(logOutAction)
```

