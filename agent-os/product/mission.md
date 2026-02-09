# Product Mission

## Problem

Deploying Kubernetes on Outscale cloud (OKS) requires assembling multiple Terraform resources manually — projects, clusters, networking, kubeconfig retrieval — with no standardized, reusable module available. Teams end up writing bespoke infrastructure code that is inconsistent, hard to maintain, and lacks production-grade defaults.

## Target Users

Any organization or developer needing Terraform modules to provision and manage Outscale Kubernetes Service (OKS) infrastructure — from small teams exploring Outscale to enterprises running production workloads.

## Solution

Provide reusable, standardized Terraform modules for OKS that follow cloud-native best practices, are production-ready out of the box, highly composable with existing Outscale networking modules, and built with security as a first-class concern. The modules offer opinionated defaults while remaining flexible enough to support diverse deployment scenarios.
