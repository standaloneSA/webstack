from django.test import TestCase
from django.utils import timezone

import datetime

from .models import Question

class QuesionModelTests(TestCase):
    def test_was_published_recently_with_future_question(self):
        """
            was_published_recently() returns False for questions whose
            pub_date is in the future
        """
        time = timezone.now() + datetime.timedelta(days=30)

        future_question = Question(pub_date = time)

        self.assertIs(future_question.was_published_recently(), False)

    def test_was_published_recently_with_old_question(self):
        """
            Checking whether old question is erroneously showing
            as a published_recently
        """
        time = timezone.now() - datetime.timedelta(days=1, seconds=1)
        old_question = Question(pub_date=time)

        self.assertIs(old_question.was_published_recently(), False)

    def test_was_published_recently_with_new_question(self):
        """
            Does a new question show published_recently?
        """
        time = timezone.now() - datetime.timedelta(hours=23, minutes=59, seconds=59)
        new_question = Question(pub_date=time)
        self.assertIs(new_question.was_published_recently(), True)