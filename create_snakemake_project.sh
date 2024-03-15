function create_snakemake_project() {
    # Default to current directory if no path is given
    project_name="$1"
    project_path="${2:-$(pwd)}"

    if [[ -z "$project_name" ]]; then
        echo "Please provide a project name."
        return 1
    fi

    full_path="$project_path/$project_name"

    # Create project directory structure
    mkdir -p "$full_path/data/raw" "$full_path/data/processed" "$full_path/envs" "$full_path/results"

    # Create a Snakefile
    cat <<EOF > "$full_path/snakefile.snk"
# Define the rule all to specify the final outputs of the workflow
rule all:
    input:
        "results/final_output.txt"

# Add your rules here
EOF

    # Create an environment YAML file
    cat <<EOF > "$full_path/envs/analysis_env.yaml"
name: analysis_env
channels:
  - conda-forge
dependencies:
  - python=3.8
  - pandas
  - numpy
  - matplotlib
EOF

    # Create a config file
    cat <<EOF > "$full_path/config.yaml"
# Configuration parameters for the workflow
data_dir: data/
results_dir: results/
EOF

    # Create a Dockerfile
    cat <<EOF > "$full_path/Dockerfile"
# Use an official Python runtime as a parent image
FROM python:3.8-slim

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy the current directory contents into the container at /usr/src/app
COPY . /usr/src/app

# Install any needed packages specified in requirements.txt
RUN pip install --trusted-host pypi.python.org -r requirements.txt

# Make port 80 available to the world outside this container
EXPOSE 80

# Define environment variable
ENV NAME World

# Run app.py when the container launches
CMD ["python", "app.py"]
EOF

    echo "Snakemake project '$project_name' created at '$full_path'"
}
