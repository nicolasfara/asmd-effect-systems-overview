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
  Tagless final keeps #bold[capabilities abstract], but the code still tends to be written in a #bold[monadic shape]:
  results stay wrapped, sequencing goes through ```scala flatMap```, and the business logic is structured around the chosen effect interface.
]

#v(0.8em)

#warning-block("Direct-style promise")[
  Keep the required effects #bold[explicit in the type], but write the implementation in a style that looks much closer to ordinary Scala.
]

== Monadic vs Direct Style

We can encode effects as capabilities, but still write in a monadic style:

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

The same requirements can be used in *direct style*:

```scala
def op(id: Int): (Config, Logger) ?=> Either[Error, Result] =
  val config = Config.config
  Logger.info(s"Processing $id")
  if id < 0 then Left(InvalidIdError)
  else Right(compute(config, id))
```

This keeps the effects visible in the signature, while making the implementation read like step-by-step code.

== Trade-offs

#components.side-by-side(inset: 0.45em, gutter: 1.1em)[
  #styled-block(
    [#fa-feather() #h(0.35em) Direct style],
    [
      #set par(leading: 0.55em)
      #text(size: 0.95em, fill: rgb("#556b74"))[
        Closer to ordinary Scala, with #underline[less ceremony] on the happy path.
      ]

      #v(0.55em)

      - Easier #bold[local reasoning].
      - Less implementation #bold[boilerplate].
      - Reads like business logic.
      - Higher-order safety is more *delicate*.
    ],
    fill-color: rgb("#fff8f1"),
    stroke-color: rgb("#f1c28a"),
    header-fill-color: rgb("#fde7cf"),
    accent-color: rgb("#eb811b"),
    title-color: rgb("#9a5408"),
  )
][
  #styled-block(
    [#fa-cubes() #h(0.35em) Monadic style],
    [
      #set par(leading: 0.55em)
      #text(size: 0.95em, fill: rgb("#556b74"))[
        #underline[Stronger compositional] structure, with sequencing kept explicit.
      ]

      #v(0.55em)

      - Very strong #bold[composition story].
      - #bold[Mature] ecosystem and libraries.
      - Explicit sequencing discipline.
      - Large stacks can become *harder to read*.
    ],
    fill-color: rgb("#f5f9fa"),
    stroke-color: rgb("#b9cdd3"),
    header-fill-color: rgb("#e7eff1"),
    accent-color: rgb("#23373b"),
    title-color: rgb("#23373b"),
  )
]

#focus-slide[
  #text(size: 1.35em)[Shift from *effects as results* to *effects as capabilities*.]
]

== How to Encode Capabilities?

We can leverage contextual abstractions to encode effects directly in the type system, without wrapping values in monads.

```scala
trait IO:
  def write(content: String): Unit
  def read[T](f: Iterator[String] => T): T

object IO:
  def write(content: String)(using io: IO): Unit =
    io.write(content)
  def read[T](f: Iterator[String] => T)(using io: IO): T =
    io.read(f)
```

Instead of returning an effect value, we require the capability that authorizes the effect.

== How to Use the Capabilities?

Using the capability is just using a context parameter in the signature.

```scala
def processFile(path: String)(using IO): Unit =
  val content = IO.read: lines =>
    lines.mkString("\n")
  IO.write(s"File content:\n$content")
```

Execution becomes “provide the handler, then run the direct-style code”.

```scala
def handle[A](program: IO ?=> A): A = ???

@main def run(): Unit =
  IO.handle:
    processFile("data.txt")
```

#focus-slide[Recall the ```scala signup``` feature]

== Required Capabilities for Sign-Up

After the encoding idea, we can move to a concrete business example.

```scala
type UserState = Map[UUID, User]

trait UserRepository:
  def get(id: UUID): Option[User]
  def save(user: User): Unit
  def changeEmail(id: UUID, newEmail: String): Unit

trait EmailService:
  def sendEmail(to: String, subject: String, body: String): Unit
```

#note-block("What the signature already says")[
  Signing up will need a #bold[repository], and an #bold[email service].
]

== Direct-Style Implementation of Sign-Up

```scala
def signup(name: Username, email: Email)(using
  UserRepository,
  EmailService
): Unit = ???
```

#feature-block("Capabilities in the signature")[
  The required capabilities are *still visible in the signature*, but the implementation can be written in a direct style.
]

== End of the World?

In #bold[monadic style], all the effects are executed at the "end of the world", when we run the program with a concrete handler.

Even in #bold[direct style], the effects are still executed at the end of the world, but the code looks more like ordinary Scala.

```scala
def myProgram(input: String)(using Effect): Unit =
  // Do some work with Effect

def handle[A](program: Effect ?=> A): A =
  given Effect with
    // Provide the implementation of Effect
  program
```

=== End of the World

```scala
@main def run(): Unit = handle { myProgram("input") }
```

== Effects as Capabilities for Failure

#feature-block("The key move")[
  Instead of saying “this computation produces an error effect”, say “this code requires the capability to throw that error”.
]

```scala
erased class CanThrow[-E <: Exception]

infix type throws[R, -E <: Exception] = CanThrow[E] ?=> R
```

- `CanThrow[E]` is the capability.
- `R throws E` is surface syntax for the same requirement.

== `throws` Is Just Syntax

```scala
enum AuthError(msg: String) extends Exception(msg):
  case InvalidEmail extends AuthError("invalid email")
  case EmailAlreadyExists extends AuthError("email already exists")

def validate(email: Email): Unit throws AuthError =
  if !email.contains("@") then throw InvalidEmail()

def validate2(email: Email)(using CanThrow[AuthError]): Unit =
  if !email.contains("@") then throw InvalidEmail()
```

#note-block("Same meaning")[
  `throws` is just a readable way to say that the function needs a `CanThrow[AuthError]` capability.
]

== Sign-Up with Checked Failure

```scala
def signup(name: Username, email: Email)(using
  UserRepository, EmailService, CanThrow[AuthError]
): User =
  validate(email)
  val user = User(UUID.randomUUID(), name, email)
  repo.save(user) // may fail with EmailAlreadyExists
  emailService.sendEmail(...)
  user
```

#feature-block("What changed?")[
  The implementation is still direct style.
  We only *added a capability* saying that failures are part of the function contract.
]

== Higher-Order Caveat

```scala
def deferredSignup(name: Username, email: Email)(using
  UserRepository, EmailService
): () => User =
  try () => signup(name, email)
  catch case _: AuthError => () => throw RuntimeException("no retry")
```

#uncover("2")[
#warning-block("Problem")[
  The returned closure can outlive the `try/catch`.
  If it still depends on the temporary throwing capability, the effect has #bold[escaped its scope].
]

We need a way to track that some capabilities are #bold[ephemeral].
]

== Capture Checking

#feature-block("Capture checking in Scala 3")[
  Capture checking tracks which values and closures depend on which capabilities, so that capabilities cannot silently escape the region where they are valid.
]

```scala
import language.experimental.captureChecking
```

- It is the missing ingredient for #bold[safer direct-style effects].
- It is especially useful for *resources*, *handlers*, *continuations*, scoped I/O, ...

== Motivating Example

```scala
def usingLogFile[T](op: FileOutputStream => T): T =
  val logFile = FileOutputStream("log")
  val result = op(logFile)
  logFile.close()
  result
```<tag>

#only("1")[
  Whats *wrong* with this code?
]

#only("2")[
This code will *crash* if higher order functions are used.

// #codly(offset-from: <tag>)
```scala
val later = usingLogFile { file => (x: Int) => file.write(x) }
later(10) // crash
```

#warning-block("Bug")[
  The returned closure captures `file`, but the file is already closed when the closure runs.
]
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
  `FileOutputStream^` is now a *capability* value:
  the compiler tracks #underline[its lifetime] and verifies that results do not carry it outside its valid scope.
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
    #uncover("2")[
    The writes happen immediately, while `f` is still valid.
    ]
  ]
][
  #warning-block("Unsafe: delayed evaluation")[
    ```scala
    val xs = usingLogFile: f =>
      LazyList(1, 2, 3).map: x =>
        f.write(x)
        x * x
    ```
    #uncover("2")[
    The work is delayed, so the file capability may be used #underline[too late].
    ]
  ]
]

== Capture Set

To *track* capabilities, the compiler "annotates" types with a #bold[set of capabilities they capture].

#v(1em)

#align(center)[
  #set text(size: 1.3em)

  `T^{C₁, C₂, ...}`
]

- `T` is a normal type.
- `C₁, C₂, ...` are the capabilities captured by values of type `T`.

=== Subtyping

- Pure types are subtypes of capturing types. That is, `T <: C T`, for any type `T`, capturing set `C`.
- For capturing types, smaller capturing sets produce subtypes: `C₁ T₁ <: C₂ T₂` if `C₁ <: C₂` and `T₁ <: T₂`.

=== Instantiation

The type ```scala T``` to be instantiated, requires the capabilities `C₁, C₂, ...` to *be in scope*.

== Function Syntax

#components.side-by-side(inset: 0.7em)[
  #feature-block("Pure function notation")[
    ```scala
    A -> B
    ```

    - The function captures #bold[nothing].
    - Think of it as a function with an #bold[empty capture set].
    - It can be passed around without depending on hidden capabilities.
  ]
][
  #warning-block("Impure function notation")[
    ```scala
    A => B
    ```

    - The function may close over #bold[arbitrary capabilities].
    - Use it when purity is #bold[not guaranteed].
    - The precise capture set can be written explicitly, e.g. `A ->{f} B`.
  ]
]

#pagebreak()

#styled-block(
  [#fa-code() #h(0.35em) Context functions follow the same idea],
  [
    - `A ?-> B`: pure context function.
    - `A ?=> B`: context function that may capture arbitrary capabilities.
  ],
  fill-color: rgb("#f9f4f0"),
  stroke-color: rgb("#c8a882"),
  header-fill-color: rgb("#f0e8e0"),
  accent-color: rgb("#c46a11"),
  title-color: rgb("#8a5a3a"),
)

#feature-block("Pure function with explicit capture set")[
  ```scala
  A ->{f} B
  ```
  This function #bold[captures the capability] `f`, and *nothing else*.
]

== Logging Example Explained

```scala
val res: Int ->{f} Unit = usingLogFile: f =>
  (x: Int) => f.write(42); x * x
```

- The type of `res` is `Int ->{f} Unit`, meaning that the returned closure captures the capability `f`.

```scala
res(10) // error: capability f is not in scope here
^^^^^^^
|The expression's type Int => Unit is not allowed to capture the root capability.
|This usually means that a capability persists longer than its allowed lifetime
```

- When the type ```scala T``` is instantiated, its capture set #bold[is not empty].
- The compiler checks that the required capabilities *are in scope*.
- In this case, `f` *is not in scope* at the call site, so the code is rejected.

// == Minimal Notation

// #components.side-by-side(inset: 0.7em)[
//   #feature-block("Capabilities and functions")[
//     - `T^`: a capability of type `T`.
//     - `A => B`: a function that may capture capabilities.
//     - `A -> B`: a pure function that captures none.
//   ]
// ][
//   #styled-block(
//     [#fa-code() #h(0.35em) Context functions],
//     [
//       #set par(leading: 0.55em)
//       #text(size: 0.95em, fill: rgb("#556b74"))[
//         Clarify function purity with explicit notation.
//       ]

//       #v(0.55em)

//       - `A ?=> B`: an impure context function.
//       - `A ?-> B`: a pure context function.
//       - Capture checking makes these distinctions statically meaningful.
//     ],
//     fill-color: rgb("#f9f4f0"),
//     stroke-color: rgb("#c8a882"),
//     header-fill-color: rgb("#f0e8e0"),
//     accent-color: rgb("#c46a11"),
//     title-color: rgb("#8a5a3a"),
//   )
// ]

== Direct-Style IO Can Also Leak

```scala
trait IO:
  def println(content: String): Unit
  def read[R](combine: Iterator[String] => R): R

type EffectIO[R] = IO ?=> R

def unsafeReadFile: EffectIO[Iterator[String]] =
  IO.read(identity)
```

#warning-block("Handler escape")[
  If `read` returns a value still tied to the handler, that value can outlive the handler and fail later with errors such as `Stream Closed`.
]

== Capture-Aware IO

```scala
trait IO:
  def println(content: String): Unit
  def read[R](combine: Iterator[String]^ => R): R

object IO:
  def handle[R](program: IO ?=> R): R =
    given IO with
      // Provide the implementation of IO
    program
```

#feature-block("Safer encoding")[
  Now the ```scala Iterator[String]``` returned by `read` is a capability, so the compiler can *track its lifetime* and prevent it from being used after the handler is gone.
]

#focus-slide[
  #text(size: 1.3em)[Direct style is pleasant, but *preserving scopes* requires #bold[capture checking].]
]

== Separation Checking

#feature-block("A different problem")[
  Capture checking controls #bold[lifetime and escape].
  Separation checking controls #bold[aliasing] when mutable capabilities are involved.
]

```scala
import language.experimental.captureChecking
import language.experimental.separationChecking
```

- Capture checking asks: “can this capability outlive its scope?”
- Separation checking asks: “can two references alias the same mutable authority?”

== Mutable Capabilities

```scala
trait Mutable extends ExclusiveCapability

class Matrix(nrows: Int, ncols: Int) extends Mutable:
  update def setElem(i: Int, j: Int, x: Double): Unit = ???
  def getElem(i: Int, j: Int): Double = ???
```

#note-block("Back to our auth example")[
  `CurrentUserState` was intentionally introduced as a mutable capability:
  separation checking is the mechanism that keeps this sort of write authority from being unsafely aliased.
]

== Matrix Multiplication

```scala
def multiply(a: Matrix, b: Matrix, c: Matrix^): Unit =
  ???
```

#components.side-by-side(inset: 0.7em)[
  #feature-block("What this tells us")[
    - `a` and `b` are read-only inputs.
    - `c` is the exclusive mutable output position.
  ]
][
  #warning-block("What is guaranteed")[
    - `multiply` cannot update `a` or `b`.
    - `c` must be distinct from `a` and `b`, preventing accidental aliasing.
  ]
]

== Takeaways

#components.side-by-side(inset: 0.7em)[
  #feature-block("Three stages of the story")[
    - Monads encode effects in #bold[values].
    - Direct style encodes effects as #bold[capabilities].
    - Capture checking makes scoped capabilities #bold[safe].
  ]
][
  #warning-block("Why the ending matters")[
    - The sign-up flow reads like ordinary code.
    - `CanThrow` keeps failure in the contract.
    - Separation checking protects mutable authority such as current-user state.
  ]
]
