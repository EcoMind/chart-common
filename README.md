# How to
- After making any changes, delete index.yaml and tgz archive, then run the following command to regenerate index.yaml and tgz file
- helm package . && helm repo index .
- then push everything on github.

# .tpl files
In the .tpl files we build the naming of resources, labels and so on.
A few examples of the standard name templating used in these files can be:
- partOf: This template defines a constant string "e4t", which can be used as a part of the label or name for Kubernetes resources.
- namespace: This template returns the namespace in which the release is being installed. It uses the Release.Namespace variable to determine the namespace.
- e4t.truncPrefix63: is used to truncate a string to 63 characters or less, which is the maximum length allowed for a Kubernetes resource name. It takes a string as input and returns a truncated version of the string if it is longer than 63 characters, otherwise it returns the original string.
- e4t.auto.component: generates a component name from the filename of the Kubernetes manifest. It takes the filename as input and returns a string that consists of the file name without the directory and ".yaml" suffix, with hyphens replacing slashes, and with any hyphen-separated words after the first word removed.
- e4t.name: generates a name for a Kubernetes resource that consists of the release name followed by a hyphen and the input string. It takes the input string as "name" and a context as "ctx" and returns the generated name.
- e4t.auto.name: generates a name for a Kubernetes resource by combining the output of the e4t.auto.component and e4t.name templates. It takes a context as input and returns the generated name.
- e4t.matchLabels: generates a set of labels for a Kubernetes resource that includes the component name, the release name, and the app name. It takes the input string as "name" and a context as "ctx" and returns the generated labels.
- e4t.auto.matchLabels: generates a set of labels for a Kubernetes resource by combining the output of the e4t.auto.component and e4t.matchLabels templates. It takes a context as input and returns the generated labels.
ecc.
