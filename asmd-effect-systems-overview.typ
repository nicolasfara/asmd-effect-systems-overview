#import "@preview/touying:0.6.3": *
#import themes.metropolis: *
#import "@preview/fontawesome:0.6.0": *
#import "@preview/ctheorems:1.1.3": *
#import "@preview/numbly:0.1.0": numbly
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#import "utils.typ": *

#show: codly-init.with()
#codly(
  languages: codly-languages,
  zebra-fill: luma(245),
  display-icon: false,
  display-name: false,
  number-placement: "outside",
  inset: 0.35em,
)

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.institution,
  config-common(
    show-bibliography-as-footnote: bibliography(title: none, "bibliography.bib"),
  ),
  config-info(
    title: [Effect Systems Overview],
    subtitle: [ASMD Course],
    author: author_list(
      (
        (first_author("Nicolas Farabegoli"), "nicolas.farabegoli@unibo.it"),
      ),
    ),
    date: datetime.today().display("[day] [month repr:long] [year]"),
    institution: [Department of Computer Science and Engineering (DISI) --- University of Bologna],
  ),
  config-colors(
    primary: rgb("#eb811b"),
    primary-light: rgb("#d6c6b7"),
    secondary: rgb("#23373b"),
    neutral-lightest: rgb("#fafafa"),
    neutral-dark: rgb("#23373b"),
    neutral-darkest: rgb("#23373b"),
  ),
  config-methods(
    init: (self: none, body) => {
      set text(font: "Fira Sans", weight: "light", size: 18pt)
      show math.equation: set text(font: "Fira Math")

      show raw.where(block: true): set text(size: 1em, font: "JetBrains Mono")
      show raw.where(block: false): set text(size: 18pt, font: "JetBrains Mono")

      show bibliography: set text(size: 0.75em)
      show footnote.entry: set text(size: 0.75em)
      set strong(delta: 200)
      set par(justify: true)
      body
    }
  )
)

#title-slide(
  extra: [
    _Material adapted from Gianluca Aguzzi and Giacomo Cavalieri_
  ]
)

// == Outline <touying:hidden>

// #components.adaptive-columns(outline(title: none, indent: 1em))

= Outline

#slide[

]

= It's All About Effects

== What is a Side Effect?

#feature-block("Side Effect")[
  A side effect is any change in *program state* or *observable behavior* beyond the function's #bold[return value].
]

#v(1em)

#components.side-by-side(inset: 0.8em)[
  #align(center)[
    #text(size: 1.5em, fill: rgb("#2e7d32"))[#fa-check-circle()]
    === Pure functions
  ]
  Only depend on their input arguments and return a value without modifying any state or performing I/O operations.
  
][
  #align(center)[
    #text(size: 1.5em, fill: rgb("#e65100"))[#fa-bolt()]
    === Impure functions
  ]
  May modify state, perform I/O operations, or have other observable behaviors beyond returning a value.
]

// == Examples of Side Effects

// #feature-block("Where Effects Show Up")[
//   Side effects appear whenever a computation *does more* than just produce a return value.
// ]

// #v(0.8em)

// #components.side-by-side[
//   #note-block("State and Local Environment", icon: fa-sliders-h() + " ")[
//     - Modifying a global variable
//     - Printing to the console
//   ]
// ][
//   #warning-block("External Interactions", icon: fa-network-wired() + " ")[
//     - Updating a database
//     - Sending a network request
//   ]
// ]

#focus-slide[
  #text(size: 1.5em)[Side effects are *lies*.]

  Your function promise to do #underline[one thing], but it also does #underline[other hidden] things.
]

== The Why and the How

#feature-block("Why should we care about side effects?")[
  / Reasoning: code becomes harder to understand because behavior depends on more than inputs and outputs.
  / Testing: reproducing behavior is harder when execution touches state, I/O, or time.
  / Concurrency: shared effects create interference, races, and subtle bugs.
  / Refactoring: changing one part of the program can trigger unexpected behavior elsewhere.
]

#warning-block("How can we control side effects?")[
  / Type Systems: make important program properties explicit instead of implicit.
  / Effect Systems: extend types so they describe not only values, but also the effects a computation may perform.
]

== Effect Systems

#feature-block("Effect System")[
  An effect system is a #bold[type system] that tracks the *side effects* of computations, allowing developers to #underline[reason about] and #underline[control] them more effectively.
]

=== Effect Systems in the Wild

- #only("2-")[Java's Checked Exceptions]
- #only("3-")[Monads in Haskell]
- #only("4-")[Koka's Algebraic Effects]
