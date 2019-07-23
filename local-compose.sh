#!/bin/sh
set -e

fail() {
    declare arg1="${1}"
    echo "${arg1}"
    printHelp
    exit 1
}

printArgHelp() {
    declare arg1="${1}" arg2="${2}"
    echo -e "${arg1}\t${arg2}"
}

printHelp() {
    printArgHelp "-h" "Prints this help."
    printArgHelp "-p" "The path the to servers tar.gz file."
    printArgHelp "-r" "Run the built docker immages with docker-compose up."
    printArgHelp "-v" "The version of WildFly to use."
    echo "Usage: ${0##*/} -v 17.0.1.Final"
}

OPTIND=1
doUp=false
distFilename=

while getopts ":hp:rv:" opt; do
    case ${opt} in
        h)
            printHelp
            exit
            ;;
        p)
            wildfly_path="${OPTARG}"
            ;;
        r)
            doUp=true
            ;;
        v)
            wildfly_version="${OPTARG}"
            ;;
        \?)
            echo "Invalid option: -${OPTARG}" >&2
            printHelp
            exit 1
            ;;
        :)
            echo "Option -${OPTARG} requires an argument" >&2
            exit 1
            ;;
    esac
done

if [ -z ${wildfly_version} ]; then
    fail "Version is required"
fi

if [ -z ${wildfly_path} ]; then
    distFilename="wildfly-dist-${wildfly_version}.tar.gz"
    wildfly_path="${HOME}/.m2/repository/org/wildfly/wildfly-dist/${wildfly_version}/${distFilename}"
else
    # Attempt to find the distribution
    for f in $(find "${wildfly_path}" -name "*-${wildfly_version}.tar.gz"); do
        echo "Found distribution ${f}"
        if [ -z ${distFilename} ]; then
            distFilename=$(basename ${f})
            wildfly_path="${f}"
        else
            echo "Multiple distributations found, using ${f}"
        fi
    done
fi

if [ ! -f ${wildfly_path} ]; then
    fail "File ${wildfly_path} does not exist. Make sure you ran mvn clean install -pl dist -Pjboss-release -Prelease -DskipTests -Dcheckstyle.skip=true -Denforcer.skip=true"
fi

echo "wildfly_version=${wildfly_version}"
echo "wildfly_path=${wildfly_path}"
cp ${wildfly_path} ./wildfly/

docker-compose -f docker-compose.yml -f docker-compose-local.yml build --build-arg WILDFLY_PATH=${distFilename} --build-arg WILDFLY_VERSION=${wildfly_version}

if [ ${doUp} == true ]; then
    docker-compose up
fi

rm -rfv ./wildfly/${distFilename}
