#import "@preview/touying:0.6.3": *
#import themes.metropolis: *
#import "@preview/fontawesome:0.6.0": *
#import "@preview/ctheorems:1.1.3": *
#import "@preview/numbly:0.1.0": numbly
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#import "@preview/cetz:0.4.2"
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

#let theorem = thmbox("theorem", "Theorem", fill: rgb("#eeffee"))
#let corollary = thmplain(
  "corollary",
  "Corollary",
  base: "theorem",
  titlefmt: strong
)
#let definition = thmbox(
  "definition",
  "Definition",
  stroke: rgb("#23373b").lighten(80%) + 1pt
).with(numbering: none)

#let example = thmplain("example", "Example").with(numbering: none)
#let proof = thmproof("proof", "Proof")

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

Once we have the ```scala IO``` monad, we can model side-effecting computations in a *pure way*. For example, we can define functions to read from the console and write to it:

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

== End-of-the-World Principle

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

#slide[
  #components.side-by-side(inset: 0.5em)[
    #feature-block("The key separation")[
      We clearly separate the *description* of the computation from its *execution*.

      // - ```scala IO[Unit]``` lives in the #bold[pure world]: it is just a value.
      // - ```scala unsafeRun``` crosses the boundary into the #bold[impure world], where effects actually happen.
    ]

    #warning-block("Do not break the boundary")[
      The #bold[effects] should only be executed at the "end of the world",
      and not inside the pure code.
    ]
  ][
    #align(center + horizon)[
      #cetz.canvas(length: 1.5cm, {
        import cetz.draw: *

        circle(
          (0, 0),
          radius: 3.2,
          fill: rgb("#fff3e0"),
          stroke: (paint: rgb("#e66a00"), thickness: 1.2pt),
        )
        circle(
          (0, 0),
          radius: 1.7,
          fill: rgb("#edf4f5"),
          stroke: (paint: rgb("#23373b"), thickness: 1.2pt),
        )

        content(
          (0, 2.25),
          text(weight: "bold", fill: rgb("#e65100"))[Impure world],
        )
        content(
          (0, 0),
          text(weight: "bold", fill: rgb("#23373b"))[Pure world],
        )
        content(
          (0, -2.35),
          box(
            inset: 0.5em,
            radius: 999pt,
            fill: white,
            stroke: (paint: rgb("#e66a00"), thickness: 0.8pt),
          )[
            #text(weight: "bold", fill: rgb("#e66a00"))[`unsafeRun`]
          ],
        )
      })
    ]
  ]
]

#slide[
  Consider the following code:

  ```scala
  def program: IO[Unit] = for
    _ <- IO.putLine("What is your name?")
    name = IO.getLine.unsafeRun() // <-- breaking the boundary!
    _ <- IO.putLine(s"Hello, $name!")
  yield ()
  ```

  ```scala name = IO.getLine.unsafeRun()``` breaks the boundary by executing the side effect inside the pure code:

  - Side effects #bold[leak] into code that should stay pure.
  - Effects happen #bold[now], not at the end of the world.
  - Testing gets harder because #bold[control is lost].
]

== Composing Effects

#feature-block("It's a matter of composition")[
  Real-world programs typically involve #bold[multiple effects] (e.g., state, I/O, exceptions) that need to be *combined* and *managed* together.
]

We need to find a way to #underline[compose different effects] in a modular and flexible way, allowing us to build complex programs while keeping the benefits of *purity* and *strong typing*.

== Motivating Example

=== Parser

A _parser_ can be seen as a computation that takes an input string and produces either a parsed value or an error if the input is invalid.

```scala
final case class Parser[A](parse: String => Option[(A, String)])
```

Taking the ```scala String``` as input, it produces an ```scala Option``` that can either be ```scala Some``` with a tuple of the parsed value and the remaining string, or ```scala None``` if parsing fails.

```scala
given Monad[Parser] with
  def pure[A](a: A): Parser[A] = Parser(input => Some((a, input)))
  def flatMap[A, B](fa: Parser[A])(f: A => Parser[B]): Parser[B] = Parser: input =>
    fa.parse(input) match
      case Some((a, rest)) => f(a).parse(rest)
      case None => None
```

#slide[
  We can easily *combine* parsers logics to build more complex ones.
  
  ```scala
  def char(c: Char): Parser[Unit] = Parser:
    case input if input.nonEmpty && input.head == c => Some(((), input.tail))
    case _ => None

  def aab(): Parser[Unit] = for
    _ <- Parser.char('a')
    _ <- Parser.char('a')
    _ <- Parser.char('b')
  yield ()

  val input = "aab"
  val result = Parser.aab().parse(input)
  println(result) // Output: Some(((), ""))
  ```
]

#focus-slide[We can do *better*]

#slide[
  The way we defined our ```scala Parser``` is similar to a ```scala State``` monad.

  ```scala
  final case class Parser[A](parse: String => Option[(A, String)])
  final case class State[S, A](run: S => (A, S))
  ```

  We can express the parser as a combination of:
  - ```scala State``` holding the input string as state.
  - ```scala Option``` representing the possibility of failure.

  We want to #bold["stack"] these effects together in a modular way, allowing us to *reuse* and *compose* them without having to #underline[rewrite the logic] for each new combination of effects.
]

= Monad Stacks

#slide[
  #definition[
    A monad transformer is a _type constructor_ that takes a monad as an argument and returns a new monad that combines the effects of both monads.
  ]

  - Allows us to #underline[compose effects] in a modular way.
  - Avoids the #bold[boilerplate] of deeply nested monads.
  - Provides a #bold[unified interface] for working with multiple effects together.

  === Notable Monad Stacks
  - ```scala EitherT[M[_], E, A]```: combines an effect `M` with error handling.
  - ```scala StateT[M[_], S, A]```: combines an effect `M` with state manipulation.
  - ```scala ReaderT[M[_], R, A]```: combines an effect `M` with read-only environment access.
  - ```scala OptionT[M[_], A]```: combines an effect `M` with optional values.
]

== Monad Transformers

Monad stacks are also called *monad transformers* because they allow us to "transform" one monad into another by adding additional effects on top of it.

Given a base monad ```scala M[_]``` (e.g., ```scala IO```),
and a #bold[transformer] ```scala T```, then ```scala T[M, A]``` (e.g., ```scala EitherT[IO, String, Int]```) is a new monad with ```scala M``` inside it.

```scala StateT[String, OptionT[IO, _], A]``` is a state monad + option + IO, allowing us to manage state, handle optional values, and perform I/O operations all in one monad.

== Monad Transformer Definition

A monad transformer can be seen as a typle of the form `(T, lift)` where:
- `T` is a *type constructor* that takes a monad `M` and produces a new monad `T[M, A]`.
- `lift` is a *polymorphic function* that takes a computation in the base monad `M` and #bold[lifts] it into the transformed monad `T[M, A]`.

```scala
trait MonadTransformer[T[_[_], _]]:
  def lift[M[_]: Monad, A](ma: M[A]): T[M, A]
```

The ```scala lift``` function is a way to #bold[inject] computations from the base monad into the transformed monad.

== Example -- OptionT

```scala
final case class OptionT[M[_], A](value: M[Option[A]])

given MonadTransformer[OptionT] with
  def lift[M[_]: Monad, A](ma: M[A]): OptionT[M, A] = OptionT(ma.map(Some(_)))
```

#align(center + horizon)[
  #cetz.canvas(length: 1cm, {
    import cetz.draw: *

    circle(
      (0, 0),
      radius: 3.1,
      fill: rgb("#edf4f5"),
      stroke: (paint: rgb("#23373b"), thickness: 1.1pt),
    )
    circle(
      (0, 0),
      radius: 1.8,
      fill: rgb("#fff3e0"),
      stroke: (paint: rgb("#e66a00"), thickness: 1.1pt),
    )

    content(
      (0, 2.2),
      text(weight: "bold", fill: rgb("#23373b"))[`M[_]`],
    )
    content(
      (0, 0.45),
      text(weight: "bold", fill: rgb("#e66a00"))[`Option`],
    )
    content(
      (0, -0.55),
      text(size: 0.95em, fill: rgb("#23373b"))[`A`],
    )

    content(
      (0, -4.0),
      box(
        inset: 0.22em,
        radius: 999pt,
        fill: white,
        stroke: (paint: rgb("#23373b").lighten(60%), thickness: 0.8pt),
      )[
        #text(size: 0.9em)[`OptionT[M, A] = M[Option[A]]`]
      ],
    )
  })
]
