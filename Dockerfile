FROM maven:3.6.3-jdk-8 as builder

WORKDIR /build

ADD . .

ARG GROUP_ID=${GROUP_ID}
ARG ARTIFACT_ID=${ARTIFACT_ID}
ARG VERSION=${VERSION}
ARG CI_PROJECT_DIR=${CI_PROJECT_DIR}
ARG CI_PIPELINE_ID=${CI_PIPELINE_ID}
ARG CI_JOB_ID=${CI_JOB_ID}
ARG MAVEN_OPTS=${MAVEN_OPTS}
ARG MAVEN_CLI_OPTS=${MAVEN_CLI_OPTS}

ENV TZ=Asia/Shanghai \
    LANG=C.UTF-8

RUN printf "GROUP_ID: %s\n" "$GROUP_ID" \
    && printf "ARTIFACT_ID: %s\n" "$ARTIFACT_ID" \
    && printf "VERSION: %s\n" "$VERSION" \
    && printf "CI_PROJECT_DIR: %s\n" "$CI_PROJECT_DIR"  \
    && printf "CI_PIPELINE_ID: %s\n" "$CI_PIPELINE_ID" \
    && printf "CI_JOB_ID: %s\n" "$CI_JOB_ID" \
    && printf "MAVEN_OPTS: %s\n" "$MAVEN_OPTS" \
    && printf "MAVEN_CLI_OPTS: %s\n" "$MAVEN_CLI_OPTS"

RUN mvn clean -e -U package -DskipTests -s settings.xml

RUN ls -l /build/target/$ARTIFACT_ID-$VERSION.jar

RUN ls -l $CI_PROJECT_DIR/.m2/repository

FROM alibabadragonwell/dragonwell:8-anolis

WORKDIR /home

ARG GROUP_ID=${GROUP_ID}
ARG ARTIFACT_ID=${ARTIFACT_ID}
ARG VERSION=${VERSION}
ARG CI_PROJECT_DIR=${CI_PROJECT_DIR}
ARG CI_PIPELINE_ID=${CI_PIPELINE_ID}
ARG CI_JOB_ID=${CI_JOB_ID}

RUN printf "GROUP_ID: %s\n" "$GROUP_ID" \
    && printf "ARTIFACT_ID: %s\n" "$ARTIFACT_ID" \
    && printf "VERSION: %s\n" "$VERSION" \
    && printf "CI_PROJECT_DIR: %s\n" "$CI_PROJECT_DIR"  \
    && printf "CI_PIPELINE_ID: %s\n" "$CI_PIPELINE_ID" \
    && printf "CI_JOB_ID: %s\n" "$CI_JOB_ID"

RUN ls -l /home

COPY --from=builder /build/target/$ARTIFACT_ID-$VERSION.jar /home/app.jar

EXPOSE 8080

ENV TZ=Asia/Shanghai \
    LANG=C.UTF-8 \
    GROUP_ID=${GROUP_ID} \
    ARTIFACT_ID=${ARTIFACT_ID} \
    VERSION=${VERSION} \
    CI_PROJECT_DIR=${CI_PROJECT_DIR} \
    CI_PIPELINE_ID=${CI_PIPELINE_ID} \
    CI_JOB_ID=${CI_JOB_ID}

CMD java -jar /home/app.jar
