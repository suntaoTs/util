#!/bin/bash

function echo_red() {
    echo -e "\E[31m${1}\E[0m"
}

function echo_green() {
    echo -e "\E[32m${1}\E[0m"
}

function echo_yellow() {
    echo -e "\E[33m${1}\E[0m"
}

function echo_blue() {
    echo -e "\E[34m${1}\E[0m"
}

function echo_pink() {
    echo -e "\E[35m${1}\E[0m"
}
