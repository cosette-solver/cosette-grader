FROM rustlang/rust:nightly-bullseye as prover-builder
RUN git clone https://github.com/cosette-solver/cosette-rs /cosette/prover
RUN apt-get update && apt-get install -y libz3-dev llvm-dev libclang-dev clang
RUN cd /cosette/prover && cargo build --release

FROM openjdk:17-jdk-bullseye as parser-builder
RUN git clone https://github.com/cosette-solver/cosette-parser /cosette/parser
RUN cd /cosette/parser && ./mvnw package

FROM gradescope/auto-builds:ubuntu-22.04
RUN apt-get update && apt-get install -y z3 libz3-dev openjdk-17-jre && rm -rf /var/lib/apt/lists/*
RUN curl https://github.com/cvc5/cvc5/releases/latest/download/cvc5-Linux --create-dirs -o /cosette/bin/cvc5
COPY --from=prover-builder /cosette/prover/target/release/cosette /cosette/bin/cosette-prover
COPY --from=parser-builder /cosette/parser/target/cosette-parser-1.0-SNAPSHOT-jar-with-dependencies.jar /cosette/lib/cosette-parser.jar
ENV PATH=/cosette/bin:$PATH
ENV CLASSPATH=/cosette/lib/cosette-parser.jar:$CLASSPATH
