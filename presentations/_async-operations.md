---
layout: presentation
title: Using Async NSOperations for the Greater Good
images: /images/presentations/async-operations
---

class: middle, center

# {{ page.title }}

---

# Introduction

--

## What does your application actually do?

--

- Loads some data from the cloud

--

- Parses the received response

--

- Performs some processing of the received data

--

- Presents the data to the user

--

- Processes user input

--

- Sends the data back to the server

---
# Async Operation

--

- Accepts some input (may be nil)

--

- Performs an asynchronous action

--

- Provides result

--

.middle.center[<img src="{{ page.images }}/async-operation-basic-form.svg"
  alt="Async Operation Basic Form" width="80%">]

---
# Async Operation

- Collect underpants

- ????

- PROFIT!

.right[<img src="{{ page.images }}/underpants-gnome.png"
  alt="South Part Underpants Gnome" height="20%">]

---
# Async Operation

- Collect underpants - _input_

- ????

- PROFIT!

---
# Async Operation

- Collect underpants - _input_

- ???? - _action_

- PROFIT!

---
# Async Operation

- Collect underpants - _input_

- ???? - _action_

- PROFIT! - _result_

--

.middle.center[<img src="{{ page.images }}/async-action-basic-form.svg"
  alt="Async Action Basic Form" width="80%">]

.left[<img src="{{ page.images }}/underpants-gnome.png"
  alt="South Part Underpants Gnome" height="20%">]

---
# Async Operation Result

- Either Value, or Error, or Cancelled

--

- Exclusively (cannot combine)

--

- Each operation ends with a result, no exceptions

--

.middle.center[<img src="{{ page.images }}/result.svg"
  alt="Async Operation Result" width="50%">]

---
# Async Operation Composition

- Perform operation A

--

- Pass its result value to the operation B as input

--

- Fail if A or B fails

--

- Cancel if A or B is cancelled

--

.middle.center[<img src="{{ page.images }}/a-then-b.svg"
  alt="Async Operation Composition" width="100%">]

---
# Async Operation Composition

- Can be considered an operation by itself

.middle.center[<img src="{{ page.images }}/composition-basic.svg"
  alt="Async operation composition is also an async operation" width="100%">]


---
# Async Operation Composition

- Can be further composed

.middle.center[<img src="{{ page.images }}/composition-a-then-b.svg"
  alt="Async operation composition can be further composed" width="100%">]


---
# Async Operation Composition

- Is associative

.middle.center[<img src="{{ page.images }}/chain-a-then-b-then-c.svg"
  alt="Async operation composition is associative" width="100%">]
