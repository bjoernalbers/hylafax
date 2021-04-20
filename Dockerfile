FROM ruby:2.0
RUN mkdir -p /opt/hylafax
WORKDIR /opt/hylafax
COPY . .
RUN bundle install --binstubs
CMD ["bash"]
