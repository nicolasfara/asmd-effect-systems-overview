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

      show raw: set text(size: 1em, font: "JetBrains Mono")

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
  An effect system is kind of a #bold[type system] that tracks the *side effects* of computations, allowing developers to #underline[reason about] and #underline[control] them more effectively.
]

=== Effect Systems in the Wild

- #only("2-")[Java's Checked Exceptions]
- #only("3-")[Monads in Haskell]
- #only("4-")[Koka's Algebraic Effects]

== Example

Throwing exceptions or errors is a *control-flow* side effect.

```scala
def divide(a: Int, b: Int): Int =
  if (b == 0) throw new Exception("Divide by zero")
  else a / b
```

- The function may fail #bold[unexpectedly] (e.g., if `b` is zero).
- Error isn't part of the #bold[function's return type], so callers may forget to handle it.
- The effects are #bold["hidden"] in the implementation, making reasoning and testing harder.

#pagebreak()

Non-determinism (random numbers, current time) is a *side effect*.

Randomness breaks *purity* as different outputs will be produced each time.

```scala
import scala.util.Random

def getRandom(): Int = Random.nextInt(100)
```

- We have no control over the output, making testing and reasoning difficult.
- The effect is hidden in the implementation, not reflected in the function's type.
- Callers may be surprised by the non-deterministic behavior.

== ???

Put a slide here motivating the need for a more general and powerful way to control effects, leading to the introduction of monads as a way to structure computations with effects in a pure functional programming language like Haskell.

= Monadic Effects

#slide[
  #feature-block("Effect concept")[
    Represents the #bold["additional context"] that computations may have beyond just producing a value, such as state changes, I/O, exceptions, etc.
  ]

  *Monads* capture effects by structuring computations in a way that allows us to sequence operations while keeping track of the effects they produce.

  #only("2")[
    ```haskell
    -- Monad definition in Haskell
    class Monad m where
      return :: a -> m a
      (>>=) :: m a -> (a -> m b) -> m b
    ```
  ]

  #only("3")[
    ```scala
    // Monad definition in Scala
    trait Monad[M[_]]:
      def pure[A](value: A): M[A]
      def flatMap[A, B](ma: M[A])(f: A => M[B]): M[B]
    ```
  ]
]

== Famous Monads

=== Absence of value
```scala Option[A]```: captures computations that may fail or return nothing.

=== Typed Failures
```scala Either[E, A]```: captures computations that may fail with an error.

=== State manipulation
```scala State[S, A]```: captures computations that manipulate state.

=== Input/Output
```scala IO[A]```: captures computations that perform input/output operations.

== IO Example

The ```scala IO``` monad is a way to model *input/output* operations in a #bold[pure functional setting].

```scala
final case class IO[A](unsafeRun: () => A)
```
- The `IO` type wraps a computation that produces a value of type `A` when executed.
- The `unsafeRun` field is a function that, when called, performs the actual I/O operation and returns the result.

```scala
given Monad[IO] with
  def pure[A](value: A): IO[A] = IO(() => value)
  def flatMap[A, B](io: IO[A])(f: A => IO[B]): IO[B] =
    IO(() => f(io.unsafeRun()).unsafeRun())
```

#uncover("2")[
  #warning-block("Do not use it in production!")[
    It #underline[lacks] features like #bold[error handling], #bold[resource management], and #bold[concurrency support].
  ]
]

#pagebreak()

Once we have the `IO` monad, we can model side-effecting computations in a pure way. For example, we can define functions to read from the console and write to it:

```scala
object IO:
  def putLine(s: String): IO[Unit] = IO(() => println(s))
  def getLine: IO[String] = IO(() => scala.io.StdIn.readLine())
```

For-comprehensions can be used to sequence these operations while keeping track of the effects:

```scala
def echo: IO[Unit] = for
  _ <- IO.putLine("Enter something:")
  input <- IO.getLine
  _ <- IO.putLine(s"You entered: $input")
yield ()
```

== End-of-the-World Problems

Trying to execute the code above we will get the following result:

```scala
IO(io.github.nicolasfara.intro.IO$given_Monad_IO$$$Lambda/0x00007f6c5569cf70)
```

This represents a value of type ```scala IO[Unit]```, which is a *description of the computation* we want to perform.

It hasn't actually executed the side effects yet. To run the side effects, we need to call `unsafeRun`:

```scala
echo.unsafeRun()
```

At this point, the side effects #bold[will be executed], and we will see the following output in the console:

```
What is your name?
Nicolas
Hello, Nicolas!
```