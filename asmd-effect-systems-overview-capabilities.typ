#import "@preview/touying:0.6.3": *
#import themes.metropolis: *
#import "@preview/fontawesome:0.6.0": *
#import "@preview/ctheorems:1.1.3": *
#import "@preview/numbly:0.1.0": numbly
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#import "@preview/cetz:0.4.2"
#import "@preview/tiaoma:0.3.0"
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
      // set raw(syntaxes: "Scala3/Scala 3.sublime-syntax")
      show link: set text(
        fill: rgb("#c46a11"),
        weight: "medium",
      )

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

== Companion Material

#align(center)[
  #tiaoma.barcode("https://github.com/nicolasfara/asmd-effect-systems-overview-code", "QRCode", options: (
    scale: 5.0,
    // fg-color: blue,
    // bg-color: green.lighten(70%),
    output-options: (
    barcode-dotty-mode: false
    ),
    dot-size: 0.8,
    )
  )

  #v(1em)

  #set text(size: 1.3em, fill: rgb("#23373b"))

  #fa-github() #h(0.5em) #link("https://github.com/nicolasfara/asmd-effect-systems-overview-code", `https://github.com/nicolasfara/asmd-effect-systems-overview-code`)
]


= Direct Style with Capabilities

== Why Another Style?

#feature-block("What changes after tagless final?")[
  Tagless final keeps #bold[capabilities abstract], but the code is still written in a #bold[monadic shape]:
  values are wrapped, sequencing goes through ```scala flatMap```, and the implementation is constrained by the chosen effect interface.
]

#v(0.8em)

#warning-block("Direct-style promise")[
  Keep the required effects #bold[explicit in the type], but write the implementation in a style that looks much closer to ordinary imperative Scala.
]

== Monadic vs Direct Style

We can encode effects as capabilities, but still write our code in a monadic style:

```scala
def op[F[_]: MonadThrow](id: Int)(using C: Config[F], L: Logger[F]): F[Result] = for
  config <- C.config
  _ <- L.info(s"Processing $id")
  result <- if id < 0 then
    InvalidIdError.raiseError[F, Result]
  else
    compute(config, id).pure[F]
yield result
```

#pagebreak()

We can rewrite this in *direct style*, using the capabilities directly without monadic wrapping:

```scala
def op(id: Int): (Config, Logger) ?=> Either[Error, Result] =
  val config = Config.config
  Logger.info(s"Processing $id")
  if id < 0 then Left(InvalidIdError)
  else Right(compute(config, id))
```

This #bold[reduces the boilerplate] and makes the code look more like ordinary Scala, while still keeping the effects *explicit* in the type signature.

== Trade-offs

#components.side-by-side(inset: 0.7em)[
  === Direct style
    - Easier local reasoning.
    - Less boilerplate in the implementation.
    - Reads like ordinary step-by-step code.
    - Higher-order safety is more delicate.
][
  === Monadic style
    - Composition story is very strong.
    - Ecosystem and libraries are mature.
    - More explicit sequencing discipline.
    - Code can become harder to read when stacks grow.
]

#focus-slide[
  #text(size: 1.35em)[Shift from *effects as results* to *effects as capabilities*.]
]

== How to Encode Capabilities?

We can leverage *Contextual Abstractions* to encode capabilities directly in the type system, without needing to wrap values in monads.

```scala
trait IO:
  def write(content: String)(using CanFail): Unit
  def read[T](f: Iterator[String] => T)(using CanFail): T

object IO:
  def write(content: String)(using IO, CanFail): Unit = summon[IO].write(content)
  def read[T](f: Iterator[String] => T)(using IO, CanFail): T = summon[IO].read(f)
```

We inverted the control flow: instead of returning an effect type, we require the capability to perform the effect as a context parameter.

== How to use the capabilities?

To use the capabilities, we simply need to provide them as context parameters in our function signatures.

```scala
def processFile(path: String)(using IO, CanFail): Unit =
  val content = IO.read: lines =>
    lines.mkString("\n")
  IO.write(s"File content:\n$content")
```

To execute this code, we need to provide an implementation of the `IO` capability and a way to handle failures:

```scala
def handle[A](program: IO ?=> A): A = ???

@main def run(): Unit = IO.handle:
  try processFile("data.txt")
  catch case _: Exception => println("An error occurred")
```

== Why Exceptions Still Matter

#feature-block("Why people keep using exceptions")[
  - Minimal boilerplate on the happy path.
  - Natural propagation of failures.
  - Debug-friendly stack traces.
]

```scala
def readFile(path: String): String =
  val source = Source.fromFile(path)
  try source.getLines().mkString("\n")
  finally source.close()
```

== Checked Exceptions and Either

#warning-block("Java checked exceptions")[
  In principle they make failures part of the contract, but they compose badly with higher-order APIs.

  ```scala
  xs.map(x => if x < limit then x * x else throw LimitExceeded())
  ```

  The callback is not allowed to throw a checked exception.
]

#pagebreak()

#feature-block([```scala Either```])[
  ```scala
  def readFile(path: String): Either[IOException, String]
  ```

  - Restores static typing.
  - Adds plumbing to the happy path.
  - Reintroduces the classic problem of composing with other effects.
]

== Effects as Capabilities

#feature-block("The key idea")[
  Instead of saying “this computation #bold[produces] an effect”, say “this code #bold[requires] the capability to perform that effect”.
]

```scala
erased class CanThrow[-E <: Exception]

infix type throws[R, -E <: Exception] = CanThrow[E] ?=> R
```

- `CanThrow[E]` is the capability.
- `R throws E` is just a more readable surface notation.

== `throws` Is Just Syntax

```scala
def f(x: Double): Double throws LimitExceeded =
  if x < limit then x * x else throw LimitExceeded()

def g(x: Double)(using CanThrow[LimitExceeded]): Double =
  if x < limit then x * x else throw LimitExceeded()
```

#note-block("Same meaning")[
  The two signatures describe the same requirement:
  the function needs the capability to throw `LimitExceeded`.
]

== LimitExceeded Example

```scala
val limit = 10e9
class LimitExceeded extends Exception

def unsafeSquare(x: Double): Double =
  if x < limit then x * x
  else throw LimitExceeded()
```

#warning-block("Compile-time feedback")[
  This definition is rejected because the body throws `LimitExceeded`,
  but the signature does not provide a `CanThrow[LimitExceeded]` capability.
]

== Where Does the Capability Come From?

```scala
def safeSquare(x: Double): Double throws LimitExceeded =
  if x < limit then x * x
  else throw LimitExceeded()

@main def test(xs: Double*) =
  try println(xs.map(safeSquare).sum)
  catch case _: LimitExceeded => println("too large")
```

#feature-block("Scoped capability")[
  The `try/catch` block is the place where the compiler can introduce the temporary capability required by `safeSquare`.
]

== Higher-Order Caveat

```scala
def escaped(xs: Double*): () => Double =
  try () => xs.map(safeSquare).sum
  catch case _: LimitExceeded => () => -1.0
```

#warning-block("Problem")[
  The closure returned by `escaped` can outlive the `try/catch` block.
  If it still depends on the throwing capability, the effect has #bold[escaped its scope].
]

#v(0.4em)

We need a way to track that these capabilities are #bold[ephemeral].

== Capture Checking

#feature-block("Capture checking in Scala 3")[
  Capture checking tracks which values and closures depend on which capabilities, so that capabilities cannot silently escape the region where they are valid.
]

```scala
import language.experimental.captureChecking
```

- It is the missing ingredient for #bold[sound direct-style effects].
- It is especially useful for resources, handlers, continuations, and scoped I/O.

== Motivating Example

```scala
def usingLogFile[T](op: FileOutputStream => T): T =
  val logFile = FileOutputStream("log")
  val result = op(logFile)
  logFile.close()
  result

val later = usingLogFile { file => (x: Int) => file.write(x) }
later(10) // crash
```

#warning-block("Bug")[
  The returned closure captures `file`, but the file is already closed when the closure runs.
]

== Make the File a Capability

```scala
def usingLogFile[T](op: FileOutputStream^ => T): T =
  val logFile = FileOutputStream("log")
  val result = op(logFile)
  logFile.close()
  result
```

#feature-block([What ```scala ^``` means])[
  `FileOutputStream^` is now a #bold[capability value]:
  the compiler tracks its lifetime and verifies that results do not carry it outside its valid scope.
]

== Why the Closure Is Rejected

#components.side-by-side(inset: 0.7em)[
  #feature-block("Core intuition")[
    - `^` marks a value whose authority matters.
    - The closure type mentions the captured file capability.
    - The result type of `usingLogFile` cannot mention a local capability that is no longer in scope.
  ]
][
  #warning-block("What the compiler prevents")[
    ```scala
    val later =
      usingLogFile { f => () => f.write(0) }
    ```

    The returned function would need to carry `f`,
    but `f` disappears at the end of `usingLogFile`.
  ]
]

== Eager vs Lazy Matters

#components.side-by-side(inset: 0.7em)[
  #feature-block("Safe: eager evaluation")[
    ```scala
    val xs = usingLogFile: f =>
      List(1, 2, 3).map: x =>
        f.write(x)
        x * x
    ```

    The writes happen immediately, while `f` is still valid.
  ]
][
  #warning-block("Unsafe: delayed evaluation")[
    ```scala
    val xs = usingLogFile: f =>
      LazyList(1, 2, 3).map: x =>
        f.write(x)
        x * x
    ```

    The work is delayed, so the file capability may be used too late.
  ]
]

== Minimal Notation

#components.side-by-side(inset: 0.7em)[
  #feature-block("Capabilities and function values")[
    - `T^`: a capability of type `T`.
    - `A => B`: an impure function that may capture arbitrary capabilities.
    - `A -> B`: a pure function that captures none.
  ]
][
  #warning-block("Context functions")[
    - `A ?=> B`: an impure context function.
    - `A ?-> B`: a pure context function.
    - Capture checking makes these differences #bold[statically meaningful].
  ]
]

== Direct-Style IO

```scala
trait IO:
  def println(content: String): Unit
  def read[R](combine: IterableOnce[String] => R): R

type EffectIO[R] = IO ?=> R
```

#feature-block("Reading the signature")[
  A program of type `EffectIO[R]` needs an `IO` capability in scope and then returns an `R`.
]

== Unsafe Handler Escape

```scala
def unsafeReadFile: EffectIO[IterableOnce[String]] =
  IO.read(identity)

def main() =
  val res = IO.runWithHandler(doubleItAndPrint(5))(using
    fileHandler(Path.of("input.txt"))
  )
  println(res)
```

#warning-block("Runtime failure")[
  If `read` returns a value still tied to the handler, that value can outlive the handler and fail later with errors like `Stream Closed`.
]

== Capture-Aware IO

```scala
trait IO:
  def println(content: String): Unit
  def read[R](combine: IterableOnce[String]^ => R): R

object IO:
  def run[R](program: EffectIO[R])(using io: IO): R^{program} =
    program(using io)
```

#feature-block("Safer encoding")[
  The callback explicitly receives a capability.
  Now the result type can record whether it depends on the surrounding program capability.
]

== Why This Helps

#components.side-by-side(inset: 0.7em)[
  #feature-block("What becomes legal")[
    - Using the handler inside the callback.
    - Producing a result that does #bold[not] retain the handler.
    - Writing direct-style programs over `IO ?=> R`.
  ]
][
  #warning-block("What becomes illegal")[
    - Returning a value that still captures the file/stream handler.
    - Smuggling scoped authority into delayed code.
    - Turning a local capability into a global one.
  ]
]

#focus-slide[
  #text(size: 1.3em)[Direct style is pleasant, but #bold[soundness for scoped effects] requires #bold[capture checking].]
]

== Separation Checking

#feature-block("A different problem")[
  Capture checking controls #bold[lifetime and escape].
  Separation checking controls #bold[aliasing] when mutable capabilities are involved.
]

- Capture checking asks: “can this capability outlive its scope?”
- Separation checking asks: “can two references alias the same mutable authority?”

== Mutable Capabilities

```scala
trait Mutable extends ExclusiveCapability

class Matrix(nrows: Int, ncols: Int) extends Mutable:
  update def setElem(i: Int, j: Int, x: Double): Unit = ???
  def getElem(i: Int, j: Int): Double = ???
```

#note-block("Minimal surface")[
  - `update` marks methods with mutation effects.
  - `Matrix^` denotes exclusive write authority.
  - Plain `Matrix` references are treated as read-only in this context.
]

== Matrix Multiplication

```scala
def multiply(a: Matrix, b: Matrix, c: Matrix^): Unit =
  ???
```

#components.side-by-side(inset: 0.7em)[
  #feature-block("What this tells us")[
    - `a` and `b` are used read-only.
    - `c` is the mutable output position.
  ]
][
  #warning-block("What is guaranteed")[
    - `multiply` cannot update `a` or `b`.
    - `c` must be distinct from `a` and `b`, preventing accidental aliasing.
  ]
]

== Takeaways

#components.side-by-side(inset: 0.7em)[
  #feature-block("Three encodings of effects")[
    - Monads encode effects in #bold[values].
    - Direct style encodes effects as #bold[capabilities].
    - Capture checking makes those capabilities #bold[scoped and safe].
  ]
][
  #warning-block("Why the ending matters")[
    - Direct style improves readability.
    - Capture checking prevents capability escape.
    - Separation checking prevents unsafe aliasing of mutable authority.
  ]
]
